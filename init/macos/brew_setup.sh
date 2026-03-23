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
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
