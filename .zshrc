# -- Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# use main_home to target only in your main user
# use $HOME to target per-user home
main_home="/home/paolo"

# -- zsh options
# https://zsh.sourceforge.io/Doc/Release/Options.html

setopt autocd # no need to write `cd` to change a directory

# completions
fpath=($main_home/.zsh/zsh-completions/src $fpath)
autoload -Uz compinit && compinit

# -- nice word jumping and deleting

autoload -U select-word-style
select-word-style bash
export WORDCHARS=''
bindkey "^[[1;5C" forward-word # ctrl + right
bindkey "^[[1;5D" backward-word # ctrl + left
bindkey "^H" backward-delete-word # ctrl + backspace
bindkey '^[[3;5~' delete-word # ctrl + delete

# -- Keep inf lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=6969696969
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

# -- colors for less
export LESS='-S -R --use-color -Dd+r$Du+b'

# -- disable microsoft spyware for dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT="1"

# -- fly.io cli
export FLYCTL_INSTALL="$main_home/.fly"

# -- some tools setup
export GOPATH="$main_home/.local/go"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PNPM_HOME="$main_home/.config/local/share/pnpm"
export ANDROID_HOME="/opt/Android/Sdk/"
export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"
export DENO_INSTALL="$main_home/.deno"
export BUN_INSTALL="$main_home/.bun"

export GITIN_LINESIZE=15
export GITIN_VIMKEYS=false
# gh: arpitbbhayani/py-prompts
#export PYTHONSTARTUP=/home/paolo/.py-prompts/themes/simple-colors.py
export WINEPREFIX=~/.wine32
export KUBE_EDITOR=micro

# -- Manual aliases
alias ls='lsd --group-dirs=first'
alias ll='ls -lh'
alias lla='ls -lha'
alias la='ls -a'
alias cat='batcat --theme=TwoDark'
alias dots="/usr/bin/git --work-tree=$HOME --git-dir=$HOME/.dotfiles"
alias gitin='gitin status'
alias grep='grep --color=always'
alias gc='git commit -v'
alias gca='git commit -v --amend'
alias zshrc="source $main_home/.zshrc"
alias docker='export UID GID; docker'
alias hexyl='hexyl --border=none'

# reverse path alias 'cd ..'
for i in {1..10}; do
  dots_alias=$(printf '.%.0s' {0..$i})
  cd_command="cd $(printf '../%.0s' {1..$i})"
  alias $dots_alias=$cd_command
done

if which kitty >/dev/null 2>&1; then
	alias ssh="kitty +kitten ssh"
	alias icat="kitty +kitten icat"
fi

# -- utilities

cap () { tee /tmp/capture.out; }
ret () { cat /tmp/capture.out; }

gclone() {
    git clone --depth=1 $1
    cloned=$(find . -maxdepth 1 -printf "%T@ %p\n" | sort -nr | awk 'NR==1 { print $2 }')
    cd $cloned
}
mkgo () { mkdir -p $1 && cd $1 }
startaws () {
    autoload bashcompinit && bashcompinit
    autoload -Uz compinit && compinit
    complete -C '/usr/local/bin/aws_completer' aws
    export AWS_PROFILE="probaar-aws-iam"
}

paths=(
  /usr/local/bin
  /usr/local/go/bin
  /opt/flutter/bin
  /opt/android-studio/bin
  /opt/Android/Sdk/cmdline-tools/latest/bin
  $GOPATH/bin
  /snap/bin
  $HOME/.local/bin
  $main_home/.config/local/share/fnm
  $main_home/.config/local/share/coursier/bin
  $HOME/.local/bin
  $PNPM_HOME
  $main_home/.dotnet
  $main_home/.scripts
  $FLYCTL_INSTALL/bin
  $DENO_INSTALL/bin
  $BUN_INSTALL/bin
  /opt/datagrip/bin/
  $main_home/.pub-cache/bin
)

for p in ${(Oa)paths}; do
  PATH=:$PATH:
  PATH=$p${PATH//:$p:/:}
  PATH=${PATH%:}
done

# -- init environments
eval "`fnm env`"
. "$main_home/.cargo/env"
[ -s "$main_home/.bun/_bun" ] && source "$main_home/.bun/_bun"

export PYENV_ROOT="$main_home/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# Load pyenv-virtualenv automatically by adding the following to ~/.bashrc:
# eval "$(pyenv virtualenv-init -)"

# -- load plugins

. ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
. ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
. ~/.zsh/zsh-completions/zsh-completions.plugin.zsh
. ~/.zsh/completion.zsh
. ~/.zsh/zsh-history.zsh
. ~/.zsh/sudo.plugin.zsh
. ~/.zsh/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
. ~/.p10k.zsh
. ~/.config/powerlevel10k/powerlevel10k.zsh-theme

# bun completions
[ -s "/home/paolo/.bun/_bun" ] && source "/home/paolo/.bun/_bun"
