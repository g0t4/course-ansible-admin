#!/usr/bin/env fish

# assumes sudoers access setup, and run script as the lowly user you want to setup (i.e. vagrant user)

# TODO port some/all of this to ansible throughout the course (when relevant to demos)

# * packages
# sudo pacman -Syu # update installed pkgs (better yet, use newer build of vagrant box w/ updates applied during packer build)
#
# FYI I confirmed these packages are not in my arch-arm vagrant box:
# sudo pacman -S --noconfirm dnsutils iputils net-tools 
#
# pipx install icdiff   # global vs per user?

function setup_user
    set user_name $argv[1]
    set home_dir $argv[2]
    set _sudo sudo -u $user_name
    set dotfiles $home_dir/repos/github/g0t4/dotfiles
    if test "$user_name" = ""
        echo "[FAIL] user name cannot be empty"
        return -1
    end
    if test "$home_dir" = ""
        echo "[FAIL] home dir cannot be empty"
        return -1
    end

    $_sudo touch $home_dir/.hushlogin

    sudo chsh -s /usr/bin/fish $user_name # avoids need for password, always run as root

    # FYI git clone effectively does a mkdir -p
    if ! $_sudo test -d $dotfiles
        $_sudo git clone https://github.com/g0t4/dotfiles.git $dotfiles
    end

    $_sudo mkdir -p $home_dir/.config/fish

    # FYI dotfiles will source this via config.fish
    $_sudo wget https://iterm2.com/shell_integration/fish -O $home_dir/.iterm2_shell_integration.fish

    $_sudo fish -c "source $dotfiles/fish/install/install.fish"

    $_sudo ln --force -s $dotfiles/fish/config/config.fish $home_dir/.config/fish/config.fish

    $_sudo ln -s $dotfiles/.grc $home_dir/.grc
    $_sudo mkdir -p $home_dir/.config/bat
    $_sudo ln -s $dotfiles/.config/bat/config $home_dir/.config/bat/config
    $_sudo ln -s $dotfiles/git/linux.gitconfig $home_dir/.gitconfig

end


# allow ssh root@r1
sudo cp $HOME/.ssh/authorized_keys /root/.ssh/authorized_keys
sudo chown -R root:root /root/.ssh
sudo chmod -R go-rwx /root/.ssh

setup_user $USER $HOME
setup_user root /root
