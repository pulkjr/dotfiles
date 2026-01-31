# Set PATH, MANPATH, etc., for Homebrew only on macOS.
if [[ "$(uname)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
