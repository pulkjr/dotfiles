#!/usr/bin/env bash
# bootstrap.sh — run this on a fresh machine BEFORE setup.sh
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/pulkjr/dotfiles/main/init/bootstrap.sh | bash
#
# What it does:
#   1. Installs Homebrew (macOS) or verifies rpm-ostree (Linux)
#   2. Installs git
#   3. Clones the dotfiles as a bare repo to ~/.dotfiles (no SSH/YubiKey needed)
#   4. Checks out files into ~/.config
#   5. Creates ~/Projects
#   6. Runs ~/.config/init/setup.sh
#
# After bootstrap completes, enroll your YubiKey SSH key and switch the remote:
#   git --git-dir=$HOME/.dotfiles --work-tree=$HOME/.config \
#     remote set-url origin git@github.com:pulkjr/dotfiles.git

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[bootstrap] $*${RESET}"; }
success() { echo -e "${GREEN}[bootstrap] $*${RESET}"; }
error()   { echo -e "${RED}[bootstrap] $*${RESET}" >&2; }

DOTFILES_REPO="https://github.com/pulkjr/dotfiles.git"
DOTFILES_BARE="$HOME/.dotfiles"
DOTFILES_DIR="$HOME/.config"

PLATFORM="$(uname)"

# ── 1. Install prerequisites ──────────────────────────────────────────────────
if [[ "$PLATFORM" == "Darwin" ]]; then
    # Install Homebrew if missing
    if ! command -v brew >/dev/null 2>&1; then
        info "Installing Homebrew..."
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
        # Add brew to PATH for Apple Silicon
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        success "Homebrew installed."
    else
        success "Homebrew already installed."
    fi

    if ! command -v git >/dev/null 2>&1; then
        info "Installing git..."
        brew install git
        success "git installed."
    else
        success "git already available."
    fi

elif [[ "$PLATFORM" == "Linux" ]]; then
    if ! command -v rpm-ostree >/dev/null 2>&1; then
        error "rpm-ostree not found. This bootstrap targets Fedora Atomic systems."
        exit 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        info "Installing git via rpm-ostree..."
        rpm-ostree install --idempotent --apply-live git
        success "git installed."
    else
        success "git already available."
    fi
else
    error "Unsupported platform: $PLATFORM"
    exit 1
fi

# ── 2. Clone dotfiles (bare repo → ~/.dotfiles, work tree → ~/.config) ────────
if [[ -d "$DOTFILES_BARE" ]]; then
    success "Bare dotfiles repo already present at $DOTFILES_BARE. Skipping clone."
else
    info "Cloning dotfiles (bare) to $DOTFILES_BARE via HTTPS..."
    git clone --bare "$DOTFILES_REPO" "$DOTFILES_BARE"
    success "Bare repo cloned."
fi

mkdir -p "$DOTFILES_DIR"

info "Checking out dotfiles to $DOTFILES_DIR..."
if ! git --git-dir="$DOTFILES_BARE" --work-tree="$DOTFILES_DIR" checkout 2>/dev/null; then
    info "Conflicting files found — backing up and retrying..."
    git --git-dir="$DOTFILES_BARE" --work-tree="$DOTFILES_DIR" checkout 2>&1 \
        | grep "^\s" | awk '{print $1}' \
        | while read -r f; do
            mkdir -p "$(dirname "$DOTFILES_DIR/$f")"
            mv "$DOTFILES_DIR/$f" "$DOTFILES_DIR/$f.bak"
          done
    git --git-dir="$DOTFILES_BARE" --work-tree="$DOTFILES_DIR" checkout
fi

# Suppress untracked files noise in dotfiles status
git --git-dir="$DOTFILES_BARE" --work-tree="$DOTFILES_DIR" \
    config --local status.showUntrackedFiles no

success "Dotfiles checked out to $DOTFILES_DIR."

# ── 3. Create ~/Projects ──────────────────────────────────────────────────────
if [[ -d "$HOME/Projects" ]]; then
    success "~/Projects already exists. Skipping."
else
    mkdir -p "$HOME/Projects"
    success "Created ~/Projects."
fi

# ── 4. Run setup.sh ───────────────────────────────────────────────────────────
SETUP_SCRIPT="$DOTFILES_DIR/init/setup.sh"
if [[ ! -f "$SETUP_SCRIPT" ]]; then
    error "setup.sh not found at $SETUP_SCRIPT. Something went wrong with the clone."
    exit 1
fi

info "Running setup.sh..."
chmod +x "$SETUP_SCRIPT"
bash "$SETUP_SCRIPT"

# ── 5. Post-bootstrap reminder ────────────────────────────────────────────────
echo ""
echo -e "${GREEN}✅ Bootstrap complete!${RESET}"
echo -e "${YELLOW}"
echo "════════════════════════════════════════════════════════"
echo " NEXT: Switch dotfiles remote to SSH"
echo ""
echo " Once your YubiKey SSH key is enrolled with GitHub, run:"
echo "   git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME/.config \\"
echo "     remote set-url origin git@github.com:pulkjr/dotfiles.git"
echo ""
echo " Verify with:"
echo "   git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME/.config remote -v"
echo "════════════════════════════════════════════════════════"
echo -e "${RESET}"
