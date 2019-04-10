#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
RESOURCDIR=$SCRIPTDIR/../res
SCRIPTUSER=$(who | cut -d " " -f1)

#======================================
# terminal setup
#======================================

chsh -s /bin/zsh $SCRIPTUSER
cd ~ && sudo -u $SCRIPTUSER sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#======================================
# i3 setup
#======================================

# variant for gdm
GDMUSERFILETEMPLATE=$RESOURCEDIR/accountservice
GDMUSERFILE=/var/lib/AccountService/users/$SCRIPTUSER
sudo -u $SCRIPTUSER cp $GDMUSERFILETEMPLATE $GDMUSERFILE
sudo -u $SCRIPTUSER echo "Icon=/home/$SCRIPTUSER/.face" >> $GDMUSERFILE

#======================================
# modify zshconfig
#======================================

#======================================
# automount windows
#======================================

