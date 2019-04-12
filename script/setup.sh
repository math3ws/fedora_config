#!/bin/sh

#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
RESOURCEDIR=$SCRIPTDIR/../res
SCRIPTUSER=$(who | cut -d " " -f1)

#======================================
# general setup
#======================================

sudo -u $SCRIPTUSER cp "$RESOURCEDIR/Xresources" "/home/$SCRIPTUSER/.Xresources"

#======================================
# zsh setup
#======================================

chsh -s /bin/zsh $SCRIPTUSER
cd ~ && sudo -u $SCRIPTUSER $SCRIPTDIR/ohmyzshsetup.sh 
sudo -u $SCRIPTUSER cp "$RESOURCEDIR/zshrc" "/home/$SCRIPTUSER/.zshrc"
sudo -u $SCRIPTUSER cp "$RESOURCEDIR/alias.zsh" "/home/$SCRIPTUSER/.oh-my-zsh/custom/alias.zsh"

#======================================
# i3 setup
#======================================

# variant for gdm:
GDMUSERFILETEMPLATE="$RESOURCEDIR/accountsservice"
GDMUSERFILE="/var/lib/AccountsService/users/$SCRIPTUSER"
cp $GDMUSERFILETEMPLATE $GDMUSERFILE
echo "Icon=/home/$SCRIPTUSER/.face" >> $GDMUSERFILE
# generic steps
I3CONFIGDIR="/home/$SCRIPTUSER/.config/i3"
mkdir -p $I3CONFIGDIR
sudo -u $SCRIPTUSER cp "$RESOURCEDIR/i3config" $I3CONFIGDIR/config"

#======================================
# automount windows
#======================================

