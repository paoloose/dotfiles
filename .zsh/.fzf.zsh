# Setup fzf
# ---------
if [[ ! "$PATH" == */home/paolo/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/paolo/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/paolo/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/paolo/.fzf/shell/key-bindings.zsh"
