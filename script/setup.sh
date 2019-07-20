#!/bin/sh

main () {
#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
RESOURCEDIR="$SCRIPTDIR/../res"
TEMPDIR="$SCRIPTDIR/../tmp"
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
# general setup
#======================================

echo "Deploying .Xresources file..."
sudo -u $SCRIPTUSER cp "$RESOURCEDIR/Xresources" "/home/$SCRIPTUSER/.Xresources"

#======================================
# i3 setup
#======================================

# gdm-specific steps:
GDMUSERFILETEMPLATE="$RESOURCEDIR/accountsservice"
GDMUSERFILE="/var/lib/AccountsService/users/$SCRIPTUSER"
SESSIONMANAGERCHANGECOMMAND="cp $GDMUSERFILETEMPLATE $GDMUSERFILE"
SESSIONMANAGERCHANGECOMMAND="$SESSIONMANAGERCHANGECOMMAND && echo \"Icon=/home/$SCRIPTUSER/.face\" >> $GDMUSERFILE"

# generic steps
I3CONFIGDIR="/home/$SCRIPTUSER/.config/i3"
I3CONFIGCOMMAND="sudo -u $SCRIPTUSER mkdir -p $I3CONFIGDIR"
I3CONFIGCOMMAND="$I3CONFIGCOMMAND && sudo -u $SCRIPTUSER cp \"$RESOURCEDIR/i3config\" \"$I3CONFIGDIR/config\""

echo "Changing session manager to i3..."
eval $SESSIONMANAGERCHANGECOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 15
fi
echo "Configuring i3..."
eval $I3CONFIGCOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 16
fi

#======================================
# zsh setup
#======================================

CHSHCOMMAND="chsh -s /bin/zsh $SCRIPTUSER"
if [ $VERBOSE -eq 0 ]; then
    CHSHCOMMAND="$CHSHCOMMAND &>/dev/null"
fi

OHMYZSHINSTALLFILE="$TEMPDIR/ohmyzshinstall.sh"
OHMYZSHINSTALLFILEURL="https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh"
OHMYZSHINSTALLCOMMAND="cd ~"
OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER mkdir -p $TEMPDIR"
OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER wget -O $OHMYZSHINSTALLFILE $OHMYZSHINSTALLFILEURL"
if [ $VERBOSE -eq 0 ]; then
     OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND --quiet"
fi
OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER sed -i.tmp '/env zsh/d' $OHMYZSHINSTALLFILE"
if [ $VERBOSE -eq 0 ]; then
     OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND --silent"
fi
OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER sed -i.tmp2 '/chsh -s/d' $OHMYZSHINSTALLFILE"
if [ $VERBOSE -eq 0 ]; then
     OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND --silent"
fi
OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND && sudo -u $SCRIPTUSER sh $OHMYZSHINSTALLFILE"
if [ $VERBOSE -eq 0 ]; then
     OHMYZSHINSTALLCOMMAND="$OHMYZSHINSTALLCOMMAND &>/dev/null"
fi

ZSHCONFIGCOMMAND="sudo -u $SCRIPTUSER cp \"$RESOURCEDIR/zshrc\" \"/home/$SCRIPTUSER/.zshrc\""
OHMYZSHCONFIGCOMMAND="sudo -u $SCRIPTUSER cp \"$RESOURCEDIR/alias.zsh\" \"/home/$SCRIPTUSER/.oh-my-zsh/custom/alias.zsh\""

echo "Changing shell to zsh..."
eval $CHSHCOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 11
fi
echo "Installing oh-my-zsh..."
eval $OHMYZSHINSTALLCOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 12
fi
echo "Configuring zsh..."
eval $ZSHCONFIGCOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 13
fi
echo "Configuring oh-my-zsh..."
eval $OHMYZSHCONFIGCOMMAND
if [ $? -ne 0 ]; then
    echo "An error occured. Exiting."
    return 14
fi
}

main

