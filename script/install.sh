#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIRPATH=$(dirname "$SCRIPTPATH")
RESOURCEPATH=$SCRIPTDIRPATH/installres

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

git clone https://github.com/math3ws/fedora_config.git $RESOURCEPATH

#======================================
# run setup script
#======================================

$RESOURCEPATH/script/setup.sh

