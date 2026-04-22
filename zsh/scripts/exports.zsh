# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export TMPDIR=/tmp

# Point starship at the config file (default search path is ~/.config/starship.toml,
# but our config lives in the starship/ subdirectory)
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

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

export MANPAGER='nvim +Man!'

# Set the default viewer for midnight commander
export VIEWER='bat'

# Location of my zettlekasten notes
export ZK_NOTEBOOK_DIR="$HOME/git/Personal/dailyZK"

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
--info=inline-right \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# Export the msbuildpath
# export MSBUILD_EXE_PATH="/usr/local/share/dotnet/sdk/$(dotnet --version)/MSBuild.dll"
# export PATH="$PATH:/usr/local/share/dotnet/sdk/$(dotnet --version)"


export PATH=$HOME/.local/bin:$PATH

# export dotnet tools
#export PATH="$PATH:$HOME/.dotnet/tools"

# macOS-only paths and library overrides
if [[ "$(uname)" == "Darwin" ]]; then
  # icu4c is keg-only on Homebrew; needed for .NET globalization on macOS
  export DYLD_LIBRARY_PATH="/opt/homebrew/opt/icu4c/lib/:${DYLD_LIBRARY_PATH:-}"

  # Homebrew Java takes precedence over macOS system Java
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
fi

# Enables full globalization support (e.g., culture-specific formatting, sorting, and parsing)
# Set to 'false' to allow .NET to use system libraries for globalization instead of invariant mode
# export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Disables .NET CLI telemetry collection
# Set to 'true' to opt out of sending usage data to Microsoft
# export DOTNET_CLI_TELEMETRY_OPTOUT=true

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

# Ignore husky on atomic workstation zsh
export HUSKY_SKIP_HOOKS=1
