#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[brew_setup] $*${RESET}"; }
success() { echo -e "${GREEN}[brew_setup] $*${RESET}"; }
error()   { echo -e "${RED}[brew_setup] $*${RESET}" >&2; }

# ── Install Homebrew if not present ─────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
    success "Homebrew already installed: $(brew --version | head -1)"
else
    info "Homebrew not found. Installing..."
    # Download to a temp file rather than piping directly into bash, so the
    # script can be inspected and its SHA256 is logged for audit purposes.
    # NOTE: Homebrew does not publish signed checksums for install.sh; the
    # SHA256 below will change with each upstream release. Cross-check it at:
    #   https://github.com/Homebrew/install/blob/HEAD/install.sh
    _brew_installer="$(mktemp /tmp/homebrew-install.XXXXXX.sh)"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
        -o "${_brew_installer}"
    info "Homebrew installer SHA256: $(sha256sum "${_brew_installer}" | awk '{print $1}')"
    NONINTERACTIVE=1 bash "${_brew_installer}"
    rm -f "${_brew_installer}"
    success "Homebrew installed."
fi

# ── Ensure brew is on PATH (Apple Silicon) ──────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Verify brew is now callable
if ! command -v brew >/dev/null 2>&1; then
    error "brew still not found after install. Aborting."
    exit 1
fi

# ── Run bundle install ───────────────────────────────────────────────────────
BREWFILE="$HOME/.config/Brewfile"

if [[ ! -f "$BREWFILE" ]]; then
    error "Brewfile not found at $BREWFILE. Skipping bundle."
else
    info "Running: brew bundle --file $BREWFILE"
    if brew bundle --file "$BREWFILE"; then
        success "brew bundle completed successfully."
    else
        error "brew bundle encountered errors (see above)."
    fi

    info "Checking bundle status..."
    if brew bundle check --file "$BREWFILE"; then
        success "All Brewfile packages are installed."
    else
        info "Some packages from $BREWFILE are not yet installed (see above)."
    fi
fi
