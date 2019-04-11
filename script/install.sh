#!/bin/sh

#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
RESOURCEDIR=$($SCRIPTDIR/installres)
SCRIPTUSER=$(who | cut -d " " -f1)

#======================================
# install packages
#======================================

PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES dmenu"
PACKAGES="$PACKAGES git"
PACKAGES="$PACKAGES i3"
PACKAGES="$PACKAGES i3lock-color"
PACKAGES="$PACKAGES i3status"
PACKAGES="$PACKAGES util-linux-user"
PACKAGES="$PACKAGES vim-enhanced"
PACKAGES="$PACKAGES zsh"

dnf copr enable -y ianhattendorf/desktop
dnf install -y $PACKAGES

#======================================
# clone git repo
#======================================

GITREMOTE=$("https://github.com/math3ws/fedora_config.git")

git -C $RESOURCEDIR ls-remote $GITREMOTE &>/dev/null
if [ $? -eq 0  ] # $RESOURCEDIR is a valid git repo pointing to $GITREMOTE
    sudo -u $SCRIPTUSER git -C $RESOURCEDIR checkout master && git -C $RESOURCEDIR pull
else # we need to clone the repo
    sudo -u $SCRIPTUSER git clone $GITREMOTE $RESOURCEDIR

#======================================
# run setup script
#======================================

$RESOURCEDIR/script/setup.sh

