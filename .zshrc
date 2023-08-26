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

# -- nice word jumping and deleting

autoload -U select-word-style
select-word-style bash
export WORDCHARS=''
bindkey "^[[1;5C" forward-word # ctrl + right
bindkey "^[[1;5D" backward-word # ctrl + left
bindkey "^H" backward-delete-word # ctrl + backspace
bindkey '^[[3;5~' delete-word # ctrl + delete

# -- Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# -- colors for less
export LESS='-R --use-color -Dd+r$Du+b'

# -- disable microsoft spyware for dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT="1"

# -- fly.io cli
export FLYCTL_INSTALL="$main_home/.fly"

# -- some tools setup
export GOPATH="$main_home/.local/go"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export DENO_INSTALL="$main_home/.deno"

export GITIN_LINESIZE=15
export GITIN_VIMKEYS=false

# -- Manual aliases
alias ls='lsd --group-dirs=first'
alias ll='ls -lh'
alias lla='ls -lha'
alias la='ls -a'
alias cat='batcat --theme=TwoDark'
alias dots="/usr/bin/git --work-tree=$HOME --git-dir=$HOME/.dotfiles"
alias gitin='gitin status'

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

mkgo () { mkdir $1 && cd $1 }

paths=(
  /usr/local/bin
  /usr/local/go/bin
  /snap/bin
  $HOME/.local/bin
  $main_home/.config/local/share/fnm
  $main_home/.config/local/share/coursier/bin
  $HOME/.local/bin
  $main_home/.dotnet
  $main_home/.scripts
  $FLYCTL_INSTALL/bin
  $DENO_INSTALL/bin
)

for p in ${(Oa)paths}; do
  PATH=:$PATH:
  PATH=$p${PATH//:$p:/:}
  PATH=${PATH%:}
done

# -- init environments
eval "`fnm env`"
. "$main_home/.cargo/env"

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
