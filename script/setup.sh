#======================================
# script variables
#======================================

# absolute path of this script file
scriptpath=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")")

# resource files
res_gdmuserfile=$scriptpath/res/accountservice

#======================================
# terminal setup
#======================================

chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#======================================
# i3 setup
#======================================

# variant for gdm
gdmuserfile=/var/lib/AccountService/users/$USERNAME
cp $res_gdmuserfile $gdmuserfile
echo "Icon=/home/$USERNAME/.face" >> $gdmuserfile

#======================================
# modify zshconfig
#======================================

#======================================
# automount windows
#======================================

