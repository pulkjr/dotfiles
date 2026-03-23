# ----------------------------------------
# Alias definitions
# ----------------------------------------
# This file centralizes all shell aliases.
# Keep it clean, consistent, and well‑documented.
# ----------------------------------------


# ----------------------------------------
# File viewing / navigation
# ----------------------------------------

alias l="eza -lh --group-directories-first --icons=auto --git"
alias la="eza -la"
alias lt="eza --tree --icons --git --level=3"
alias ll="eza -lah --icons --group-directories-first"

# ----------------------------------------
# System monitoring / disk usage
# ----------------------------------------

# Use htop instead of top (better UI)
alias top='htop'

# Use ncdu instead of du (interactive disk usage)
#   --color dark : dark theme
#   -rr          : read‑only mode (no delete, no shell)
#   -x           : stay on same filesystem
#   --exclude    : ignore directories we don’t care about
alias du='ncdu --color dark -rr -x --exclude .git --exclude node_modules'

# ----------------------------------------
# Development tools
# ----------------------------------------

# Always use pip3
# alias pip='pip3'

# Lazygit
alias lz="lazygit"

# ----------------------------------------
# Tmux
# ----------------------------------------

# Always start tmux using the XDG config
alias tmux='tmux -f ~/.config/tmux/tmux.conf'


# ----------------------------------------
# Dotfiles management
# ----------------------------------------
# Bare repo at ~/.dotfiles, work tree at ~/.config

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME/.config"

# Manage dotfiles with lazygit
alias lzdot="lazygit -g $HOME/.dotfiles -w $HOME/.config"
alias lzconfig="lazygit -g $HOME/.dotfiles -w $HOME/.config"

#----------------------------------------
# Timewarrior & Taskwarrior
# ----------------------------------------
alias tw="timew"

# ----------------------------------------
# Containers
# ----------------------------------------
# alias docker="podman"
# alias docker-compose="podman-compose"
