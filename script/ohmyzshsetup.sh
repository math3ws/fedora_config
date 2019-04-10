#!/bin/sh

#======================================
# script variables
#======================================

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
RESOURCDIR=$SCRIPTDIR/../res
TEMPDIR=$SCRIPTDIR/../tmp
SCRIPTUSER=$(who | cut -d " " -f1)

#======================================
# download and install oh-my-zsh 
#======================================

OHMYZSHINSTALLFILE=$TEMPDIR/ohmyzshinstall.sh
mkdir -p $TEMPDIR
wget -O $OHMYZSHINSTALLFILE  https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
sed -i.tmp '/env zsh/d' $OHMYZSHINSTALLFILE
sed -i.tmp '/chsh -s/d' $OHMYZSHINSTALLFILE
sh $OHMYZSHINSTALLFILE &>/dev/null

