#======================================
# script variables
#======================================

# absolute path of this script file
scriptpath=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")")
resourcepath=$scriptdir/installres

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
# clone git repo
#======================================

git clone https://github.com/math3ws/fedora_config.git $resourcepath

#======================================
# run setup script
#======================================

$resourcepath/script/setup.sh

