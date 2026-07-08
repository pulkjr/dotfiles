export TMPDIR=/tmp

# Point starship at the config file (default search path is ~/.config/starship.toml,
# but our config lives in the starship/ subdirectory)
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

#Use fzf-tmux
export FZF_TMUX=1

export FZF_DEFAULT_OPTS="
--layout=reverse
--bind='ctrl-e:execute(nvim {})+abort'
--bind 'ctrl-a:select-all'"

# The command to use instead of find.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Default editor (nvim in container via nvim() function)
export EDITOR='nvim'
export MANPAGER='nvim +Man!'

# Location of my zettlekasten notes
export ZK_NOTEBOOK_DIR="$HOME/projects/personal/zk"

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
--info=inline-right \
--color=bg+:#282c34,bg:#1e2127,spinner:#c678dd,hl:#e06c75 \
--color=fg:#abb2bf,header:#61afef,info:#c678dd,pointer:#61afef \
--color=marker:#98c379,fg+:#abb2bf,prompt:#61afef,hl+:#e06c75 \
--color=selected-bg:#3e4452 \
--multi"

export PATH=$HOME/.local/bin:$PATH

# Use podman as the Docker-compatible runtime
# DOCKER_HOST must be a unix socket URI, not a binary path
if command -v podman &>/dev/null; then
  export DOCKER_PATH="$(command -v podman)"
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: podman machine exposes a socket via the default machine
    export DOCKER_HOST="unix://${HOME}/.local/share/containers/podman/machine/qemu/podman.sock"
  else
    # Linux: rootless podman socket via systemd user session
    export DOCKER_HOST="unix:///run/user/${UID}/podman/podman.sock"
  fi
fi

# Bitwarden — restore session token from previous unlock
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS: read from Keychain (never touches disk as plaintext)
  if _bw_session=$(security find-generic-password -w -s "bitwarden-session" -a "$USER" 2>/dev/null); then
    export BW_SESSION="$_bw_session"
  fi
  unset _bw_session
elif [[ -f "$HOME/.bw_session" ]]; then
  # Linux: read from file, ensure permissions are still tight
  chmod 600 "$HOME/.bw_session"
  export BW_SESSION="$(< "$HOME/.bw_session")"
fi
