#!/bin/bash

#======================================
# setup global script variables
#======================================
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
REPODIR="/tmp/fedora-config"
TEMPDIR="$REPODIR/tmp"
RESOURCEDIR="$REPODIR/res"
SCRIPTUSER=$(who | cut -d " " -f1)
VERBOSE=0

#======================================
# install packages passed in arguments
#======================================
installPackages() {
    local PACKAGEINSTALLCOMMAND="dnf install -y $@"
    if [ $VERBOSE -eq 0 ]; then
        PACKAGEINSTALLCOMMAND="$PACKAGEINSTALLCOMMAND -q &>/dev/null"
    fi

    eval $PACKAGEINSTALLCOMMAND
    return $?
}

#======================================
# check that the script is ran as root
#======================================
isRanAsRoot() {
    echo "Checking if script is ran as root..."

    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 
        return 1
    fi
}

#======================================
# install basic dependencies
#======================================
installBasicDependencies() {
    echo "Installing basic dependencies..."

    local PACKAGES="coreutils"
    PACKAGES="$PACKAGES util-linux"
    PACKAGES="$PACKAGES sudo"

    installPackages $PACKAGES
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 2
    fi
}

#======================================
# argument parsing
#======================================
parseArguments() {
    # -allow a command to fail with !’s side effect on errexit
    # -use return value from ${PIPESTATUS[0]}, because ! hosed $?
    ! getopt --test > /dev/null
    if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
        echo '`getopt --test` failed in this environment'
        return 1
    fi

    local OPTIONS=v
    local LONGOPTIONS=verbose

    # -regarding ! and PIPESTATUS see above
    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out “--options”)
    # -pass arguments only via   -- "$@"   to separate them correctly
    ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        # e.g. return value is 1
        #  then getopt has complained about wrong arguments to stdout
        return 1
    fi
    # read getopt’s output this way to handle the quoting right:
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unknown option passed to install.sh"
                return 2
                ;;
        esac
    done
}

#======================================
# enable third party dnf repos
#======================================
enableRepos() {
    echo "Enabling third-party repos..."

    local REPOENABLECOMMAND="dnf copr enable -y ianhattendorf/desktop"

    if [ $VERBOSE -eq 0 ]; then
        REPOENABLECOMMAND="$REPOENABLECOMMAND -q &>/dev/null"
    fi

    eval $REPOENABLECOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 1
    fi
}

#======================================
# install packages
#======================================
installRequiredPackages() {
    echo "Installing required packages..."

    local PACKAGES="dmenu"
    PACKAGES="$PACKAGES git"
    PACKAGES="$PACKAGES i3"
    PACKAGES="$PACKAGES i3lock-color"
    PACKAGES="$PACKAGES i3status"
    PACKAGES="$PACKAGES util-linux-user"
    PACKAGES="$PACKAGES wget"
    PACKAGES="$PACKAGES zsh"

    installPackages $PACKAGES
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 2
    fi
}

#======================================
# clone git repo
#======================================
cloneResources() {
    echo "Checking if resources are available..."

    local GITREMOTE="git@github.com:math3ws/fedora_config.git"

    local GITCOMMAND=""
    sudo -u $SCRIPTUSER git -C $REPODIR ls-remote $GITREMOTE &>/dev/null
    if [ $? -eq 0  ]; then # $RESOURCEDIR is a valid git repo pointing to $GITREMOTE
        echo "Resources available. Checking out latest version..."
        GITCOMMAND="sudo -u $SCRIPTUSER git -C $REPODIR checkout master"
        if [ $VERBOSE -eq 0 ]; then
            GITCOMMAND="$GITCOMMAND -q"
        fi
        GITCOMMAND="$GITCOMMAND && sudo -u $SCRIPTUSER git -C $REPODIR pull"
        if [ $VERBOSE -eq 0 ]; then
            GITCOMMAND="$GITCOMMAND -q"
        fi
    else # we need to clone the repo
        echo "Resources not available. Cloning repository..."
        GITCOMMAND="sudo -u $SCRIPTUSER git clone $GITREMOTE $REPODIR"
        if [ $VERBOSE -eq 0 ]; then
            GITCOMMAND="$GITCOMMAND -q"
        fi
    fi

    eval $GITCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 3
    fi
}

#======================================
# Xresources setup
#======================================
setupXresources() {
    echo "Deploying .Xresources file..."

    sudo -u $SCRIPTUSER cp "$RESOURCEDIR/Xresources" "/home/$SCRIPTUSER/.Xresources"
}

#======================================
# i3 setup
#======================================
setupI3() {
    echo "Configuring i3..."

    local I3CONFIGDIR="/home/$SCRIPTUSER/.config/i3"
    local I3CONFIGCOMMAND="sudo -u $SCRIPTUSER mkdir -p $I3CONFIGDIR"
    I3CONFIGCOMMAND="$I3CONFIGCOMMAND && sudo -u $SCRIPTUSER cp \"$RESOURCEDIR/i3config\" \"$I3CONFIGDIR/config\""

    eval $I3CONFIGCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 16
    fi
}

#======================================
# session manager setup
#======================================
changeSessionManager() {
    echo "Changing session manager to i3..."

    # gdm-specific steps:
    local GDMUSERFILETEMPLATE="$RESOURCEDIR/accountsservice"
    local GDMUSERFILE="/var/lib/AccountsService/users/$SCRIPTUSER"
    local SESSIONMANAGERCHANGECOMMAND="cp $GDMUSERFILETEMPLATE $GDMUSERFILE"
    SESSIONMANAGERCHANGECOMMAND="$SESSIONMANAGERCHANGECOMMAND && echo \"Icon=/home/$SCRIPTUSER/.face\" >> $GDMUSERFILE"

    eval $SESSIONMANAGERCHANGECOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 15
    fi
}

#======================================
# shell change
#======================================
changeShell() {
    echo "Changing shell to zsh..."

    local CHSHCOMMAND="chsh -s /bin/zsh $SCRIPTUSER"
    if [ $VERBOSE -eq 0 ]; then
        CHSHCOMMAND="$CHSHCOMMAND &>/dev/null"
    fi

    eval $CHSHCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 11
    fi
}

#======================================
# oh-my-zsh installation
#======================================
installOhMyZsh() {
    echo "Installing oh-my-zsh..."

    local OHMYZSHINSTALLFILE="$TEMPDIR/ohmyzshinstall.sh"
    local OHMYZSHINSTALLFILEURL="https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
    local OHMYZSHINSTALLCOMMAND="sudo -u $SCRIPTUSER mkdir -p $TEMPDIR"
    OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER rm -rf ~$SCRIPTUSER/.oh-my-zsh"
    OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER wget -O $OHMYZSHINSTALLFILE $OHMYZSHINSTALLFILEURL"
    if [ $VERBOSE -eq 0 ]; then
         OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND --quiet"
    fi
    OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER sh $OHMYZSHINSTALLFILE --unattended"
    if [ $VERBOSE -eq 0 ]; then
         OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND &>/dev/null"
    fi

    eval $OHMYZSHINSTALLCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 12
    fi
}

#======================================
# zsh config
#======================================
setupZsh() {
    echo "Configuring zsh..."

    local ZSHCONFIGCOMMAND="sudo -u $SCRIPTUSER cp \"$RESOURCEDIR/zshrc\" \"/home/$SCRIPTUSER/.zshrc\""

    eval $ZSHCONFIGCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 13
    fi
}

#======================================
# oh-my-zsh config
#======================================
setupOhMyZsh () {
    echo "Configuring oh-my-zsh..."

    local OHMYZSHCONFIGCOMMAND="sudo -u $SCRIPTUSER cp \"$RESOURCEDIR/alias.zsh\" \"/home/$SCRIPTUSER/.oh-my-zsh/custom/alias.zsh\""

    eval $OHMYZSHCONFIGCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 14
    fi
}

#======================================
# install packages
#======================================
installOptionalPackages() {
    echo "Installing optional packages..."

    local PACKAGES="git-gui"
    PACKAGES="$PACKAGES aspell-en"
    PACKAGES="$PACKAGES aspell-cs"
    PACKAGES="$PACKAGES boost"
    PACKAGES="$PACKAGES boost-devel"
    PACKAGES="$PACKAGES clang"
    PACKAGES="$PACKAGES clang-devel"
    PACKAGES="$PACKAGES clang-tools-extra"
    PACKAGES="$PACKAGES lld"
    PACKAGES="$PACKAGES lldb"
    PACKAGES="$PACKAGES qt-creator"
    PACKAGES="$PACKAGES qt5-*"
    PACKAGES="$PACKAGES cmake"
    PACKAGES="$PACKAGES vim-enhanced"

    installPackages $PACKAGES
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 2
    fi
}

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

isRanAsRoot && \
installBasicDependencies && \
parseArguments "$@" && \
enableRepos && \
installRequiredPackages && \
cloneResources && \
setupXresources && \
setupI3 && \
changeSessionManager && \
changeShell && \
installOhMyZsh && \
setupZsh && \
setupOhMyZsh && \
installOptionalPackages
