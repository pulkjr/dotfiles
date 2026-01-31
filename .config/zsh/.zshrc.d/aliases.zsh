# ----------------------------------------
# Alias definitions
# ----------------------------------------
# This file centralizes all shell aliases.
# Keep it clean, consistent, and well‑documented.
# ----------------------------------------


# ----------------------------------------
# File viewing / navigation
# ----------------------------------------

alias ls="eza -lh --group-directories-first --icons=auto --git"
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
alias pip='pip3'

# Use Neovim instead of Vim
alias vim='nvim'

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

# Manage dotfiles stored in ~/.dotfiles
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Manage dotfiles with lazygit
alias lzdiff="GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME lazygit"
alias lzconfig="GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME lazygit"

# ----------------------------------------
# Misc
# ----------------------------------------

# Launch VS Code with TLS disabled (for Sourcegraph)
alias code="node_tls_reject_unauthorized=0 code"

#----------------------------------------
# Timewarrior & Taskwarrior
# ----------------------------------------
alias tw="timew"

# ----------------------------------------
# Containers
# ----------------------------------------
# alias docker="podman"
# alias docker-compose="podman-compose"
