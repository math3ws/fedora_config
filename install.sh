# install packages

dnf copr enable -y ianhattendorf/desktop

packages="$packages curl"
packages="$packages dmenu"
packages="$packages git"
packages="$packages i3"
packages="$packages i3lock-color"
packages="$packages i3status"
packages="$packages util-linux-user"
packages="$packages vim-enhanced"
packages="$packages zsh"

dnf install -y zsh $packages

# shell setup
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# modify zshconfig

# automount windows

