#!/bin/sh

main () {
#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
RESOURCEDIR="$SCRIPTDIR/installres"
SCRIPTUSER=$(who | cut -d " " -f1)
VERBOSE=0

#======================================
# argument parsing
#======================================

while getopts v: opt; do
    case $opt in
        v) $VERBOSE=1
	   ;;
    esac
done

#======================================
# install packages
#======================================

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

REPOENABLECOMMAND="dnf copr enable -y ianhattendorf/desktop"
PACKAGEINSTALLCOMMAND="dnf install -y $PACKAGES"
if [ $VERBOSE -eq 0 ]; then
    REPOENABLECOMMAND="$REPOENABLECOMMAND -q"
    PACKAGEINSTALLCOMMAND="$PACKAGEINSTALLCOMMAND -q"
fi

eval $REPOENABLECOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 1
fi
eval $PACKAGEINSTALLCOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 2
fi

#======================================
# clone git repo
#======================================

echo "Checking if resources are available..."

GITREMOTE="https://github.com/math3ws/fedora_config.git"

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

#======================================
# run setup script
#======================================

$RESOURCEDIR/script/setup.sh
}

main

