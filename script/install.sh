#!/bin/bash

#======================================
# check that the script is ran as root
#======================================
isRanAsRoot () {
    echo "Checking if script is ran as root..."
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 
        return 1
    fi
}

#======================================
# setup script variables
#======================================
setupProgramSettings () {
    SCRIPTPATH=$(readlink -f "$0")
    SCRIPTDIR=$(dirname "$SCRIPTPATH")
    RESOURCEDIR="/tmp/fedora-config"
    SCRIPTUSER=$(who | cut -d " " -f1)
    VERBOSE=0
}

#======================================
# argument parsing
#======================================
parseArguments() {
    # saner programming env: these switches turn some bugs into errors
    set -o errexit -o pipefail -o noclobber -o nounset

    # -allow a command to fail with !’s side effect on errexit
    # -use return value from ${PIPESTATUS[0]}, because ! hosed $?
    ! getopt --test > /dev/null
    if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
        echo '`getopt --test` failed in this environment'
        return 1
    fi

    OPTIONS=v
    LONGOPTS=verbose

    # -regarding ! and PIPESTATUS see above
    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out “--options”)
    # -pass arguments only via   -- "$@"   to separate them correctly
    ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
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
                v=1
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
enableRepos () {
    echo "Enabling third-party repos..."

    REPOENABLECOMMAND="dnf copr enable -y ianhattendorf/desktop"

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
installPackages() {
    echo "Installing required packages..."

    PACKAGES="$PACKAGES curl"
    PACKAGES="$PACKAGES dmenu"
    PACKAGES="$PACKAGES git"
    PACKAGES="$PACKAGES i3"
    PACKAGES="$PACKAGES i3lock-color"
    PACKAGES="$PACKAGES i3status"
    PACKAGES="$PACKAGES util-linux-user"
    PACKAGES="$PACKAGES vim-enhanced"
    PACKAGES="$PACKAGES zsh"

    PACKAGEINSTALLCOMMAND="dnf install -y $PACKAGES"
    if [ $VERBOSE -eq 0 ]; then
        PACKAGEINSTALLCOMMAND="$PACKAGEINSTALLCOMMAND -q &>/dev/null"
    fi

    eval $PACKAGEINSTALLCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 2
    fi
}

#======================================
# clone git repo
#======================================
cloneResources () {
    echo "Checking if resources are available..."

    GITREMOTE="git@github.com:math3ws/fedora_config.git"

    GITCOMMAND=""
    git -C $RESOURCEDIR ls-remote $GITREMOTE &>/dev/null
    if [ $? -eq 0  ]; then # $RESOURCEDIR is a valid git repo pointing to $GITREMOTE
        echo "Resources available. Checking out latest version..."
        GITCOMMAND="sudo -u $SCRIPTUSER git -C $RESOURCEDIR checkout master"
        if [ $VERBOSE -eq 0 ]; then
            GITCOMMAND="$GITCOMMAND -q"
        fi
        GITCOMMAND="$GITCOMMAND && git -C $RESOURCEDIR pull"
        if [ $VERBOSE -eq 0 ]; then
            GITCOMMAND="$GITCOMMAND -q"
        fi
    else # we need to clone the repo
        echo "Resources not available. Cloning repository..."
        GITCOMMAND="sudo -u $SCRIPTUSER git clone $GITREMOTE $RESOURCEDIR"
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
# run install_impl.sh script
#======================================
runInstallImpl() {
    $RESOURCEDIR/script/install_impl.sh
}

#======================================
# run install_impl.sh script
#======================================
runInstallOptional() {
    $RESOURCEDIR/script/install_optional.sh
}

isRanAsRoot && setupProgramSettings && parseArguments && enableRepos && installPackages && cloneResources && runInstallImpl && runInstallOptional

