#Use fzf-tmux
export FZF_TMUX=1

# When you click ctrl+o then it will open the file in vscode
export FZF_DEFAULT_OPTS="
--layout=reverse
--bind='ctrl-o:execute(code {})+abort'
--bind 'ctrl-a:select-all'"

# The command to use instead of find.
export FZF_DEFAULT_COMMAND='ag --hidden --norecurse --ignore .git -g ""'

# Set the default editor to helix
export EDITOR='nvim'

# Set the default viewer for midnight commander
export VIEWER='bat'

# Location of my zettlekasten notes
export ZK_NOTEBOOK_DIR='/Users/jpulk/git/Personal/dailyZK'
