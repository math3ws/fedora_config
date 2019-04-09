#======================================
# script variables
#======================================

# absolute path of this script file
scriptpath=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")")

# resource files
res_gdmuserfile=$scriptpath/res/accountservice

#======================================
# install packages
#======================================

packages="$packages curl"
packages="$packages dmenu"
packages="$packages git"
packages="$packages i3"
packages="$packages i3lock-color"
packages="$packages i3status"
packages="$packages util-linux-user"
packages="$packages vim-enhanced"
packages="$packages zsh"

dnf copr enable -y ianhattendorf/desktop
dnf -y update
dnf install -y $packages

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

