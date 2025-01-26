# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

#Use fzf-tmux
export FZF_TMUX=1

# When you click ctrl+o then it will open the file in vscode
export FZF_DEFAULT_OPTS="
--layout=reverse
--bind='ctrl-e:execute(nvim {})+abort'
--bind 'ctrl-a:select-all'"

# The command to use instead of find.
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# Set the default editor to NVIM!!
export EDITOR='nvim'

# Set the default viewer for midnight commander
export VIEWER='bat'

# Location of my zettlekasten notes
export ZK_NOTEBOOK_DIR='/Users/jpulk/git/Personal/dailyZK'


export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none
  --color=bg+:#283457 \
  --color=bg:#16161e \
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
"

