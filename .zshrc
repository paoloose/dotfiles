# -- Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# -- Disable microsoft spyware for dotnet

export DOTNET_CLI_TELEMETRY_OPTOUT="1"

# -- Manual aliases

alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='batcat'
alias dotfiles="/usr/bin/git --work-tree=$HOME --git-dir=$HOME/.dotfiles"
alias icat="kitty +kitten icat"

# useful for capturing output of commands
cap () { tee /tmp/capture.out; }
ret () { cat /tmp/capture.out; }

# path
if [ $USER = "root" ]; then
    export PATH=$HOME/.local/bin:$HOME/.local/share/fnm:$PATH
else
    export PATH=$HOME/.local/bin:$HOME/.scripts:$HOME/.config/local/share/fnm:$PATH
fi

# -- fnm
eval "`fnm env`"

# -- pnpm
export PNPM_HOME=$HOME/.config/local/share/pnpm
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

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
