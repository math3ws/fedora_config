#!/bin/sh

#======================================
# setup script variables
#======================================
setupProgramSettings () {
    SCRIPTPATH=$(readlink -f "$0")
    SCRIPTDIR=$(dirname "$SCRIPTPATH")
    RESOURCEDIR="/tmp/fedora-config"
    SCRIPTUSER=$(who | cut -d " " -f1)
    VERBOSE=0
}

#======================================
# argument parsing
#======================================
parseArguments() {
    while getopts v: opt; do
        case $opt in
            v) $VERBOSE=1
	        ;;
        esac
    done
}

#======================================
# install packages
#======================================
installPackages() {
    echo "Installing required packages..."

    PACKAGES="$PACKAGES git-gui"
    PACKAGES="$PACKAGES aspell-en"
    PACKAGES="$PACKAGES aspell-cs"
    PACKAGES="$PACKAGES boost"
    PACKAGES="$PACKAGES boost-devel"
    PACKAGES="$PACKAGES clang"
    PACKAGES="$PACKAGES clang-devel"
    PACKAGES="$PACKAGES clang-tools-extra"
    PACKAGES="$PACKAGES lld"
    PACKAGES="$PACKAGES lldb"
    PACKAGES="$PACKAGES qt-creator"
    PACKAGES="$PACKAGES 'qt5-*'"

    PACKAGEINSTALLCOMMAND="dnf install -y $PACKAGES"
    if [ $VERBOSE -eq 0 ]; then
        PACKAGEINSTALLCOMMAND="$PACKAGEINSTALLCOMMAND -q &>/dev/null"
    fi

    eval $PACKAGEINSTALLCOMMAND
    if [ $? -ne 0 ]; then
        echo "An error occured. Exiting."
        return 2
    fi
}

setupProgramSettings && parseArguments && installPackages
