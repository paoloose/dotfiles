git clone --bare https://github.com/paoloose/dotfiles $HOME/.dotfiles

function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME $@
}

mkdir -p .dotfiles-backup

# Try to checkout (and resolve conflicts)
dotfiles checkout

if [ $? -ne 0 ]; then
    echo "Backing up pre-existing dot files.";
    dotfiles checkout 2>&1 | egrep "^\s" | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
    echo "Backup done. See .dotfiles.backup"
fi

echo "Checked out config. Enjoy! (after fixing it)"

dotfiles checkout

dotfiles config status.showUntrackedFiles no

# Modified from https://bitbucket.org/durdn/cfg/raw/master/.bin/install.sh
