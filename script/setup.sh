#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIRPATH=$(dirname "$SCRIPTPATH")
RESOURCEPATH=$SCRIPTDIRPATH/res

#======================================
# terminal setup
#======================================

chsh -s /bin/zsh $USERNAME
cd ~ && sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#======================================
# i3 setup
#======================================

# variant for gdm
GDMUSERFILETEMPLATE=$RESOURCEPATH/accountservice
GDMUSERFILE=/var/lib/AccountService/users/$USERNAME
cp $GDMUSERFILETEMPLATE $GDMUSERFILE
echo "Icon=/home/$USERNAME/.face" >> $GDMUSERFILE

#======================================
# modify zshconfig
#======================================

#======================================
# automount windows
#======================================

