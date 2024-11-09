# A location to put all of my aliases.

# open bat no matter what!!
alias cat='bat'

# Use htop insteal of top
alias top='htop'

# Use batman insteal of man
alias man='batman'

# ll will open a preview of the files
#alias ll="fzf --preview 'bat --color \"always\" --style=numbers --line-range=:500 {}'"

# ncdu > du
# --color dark - use a colour scheme
# -rr - read-only mode (prevents delete and spawn shell)
# --exclude ignore directories I won't do anything about
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"

# alias pip with pip3
alias pip="pip3"

alias vim="nvim"

# Command to manage dotfiles with git
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
