#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[linux-setup] $*${RESET}"; }
success() { echo -e "${GREEN}[linux-setup] $*${RESET}"; }
error()   { echo -e "${RED}[linux-setup] $*${RESET}" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Verify platform tools ─────────────────────────────────────────────────────
if ! command -v rpm-ostree >/dev/null 2>&1; then
    error "rpm-ostree not found. This script targets Fedora Atomic systems."
    exit 1
fi

if ! command -v flatpak >/dev/null 2>&1; then
    error "flatpak not found. Please install flatpak first."
    exit 1
fi

# ── rpm-ostree packages ───────────────────────────────────────────────────────
RPM_PACKAGES=(
    git
    tmux
    zsh
    podman
    bitwarden-cli
    libfido2
    yubikey-manager
    pcsc-lite
    pcsc-lite-ccid
    task
    timew
)

info "Installing core CLI packages via rpm-ostree (idempotent)..."
rpm-ostree install --idempotent --apply-live "${RPM_PACKAGES[@]}"
success "rpm-ostree packages installed."

# ── Flatpak setup ─────────────────────────────────────────────────────────────
info "Adding Flathub remote (if not present)..."
flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
success "Flathub remote configured."

FLATPAK_APPS=(
    com.google.Chrome
    app.ghosts.Ghostty
    com.spotify.Client
    com.microsoft.Teams
    md.obsidian.Obsidian
)

for app in "${FLATPAK_APPS[@]}"; do
    if flatpak list --app --columns=application | grep -q "^${app}$"; then
        success "Flatpak '$app' already installed. Skipping."
    else
        info "Installing Flatpak: $app"
        flatpak install -y flathub "$app" || error "Failed to install $app (may not exist on flathub, continuing)"
    fi
done

# ── Shell symlinks ────────────────────────────────────────────────────────────
make_symlink() {
    local target="$1"
    local link="$2"

    if [[ -L "$link" ]]; then
        current_target="$(readlink "$link")"
        if [[ "$current_target" == "$target" ]]; then
            success "$link → $target (already correct, skipping)"
            return
        else
            info "$link points to '$current_target'. Updating..."
            rm "$link"
        fi
    elif [[ -e "$link" ]]; then
        info "$link exists and is not a symlink. Backing up to ${link}.bak"
        mv "$link" "${link}.bak"
    fi

    ln -s "$target" "$link"
    success "Created $link → $target"
}

make_symlink "$HOME/.config/zsh/.zshrc"    "$HOME/.zshrc"
make_symlink "$HOME/.config/zsh/.zprofile" "$HOME/.zprofile"
make_symlink "$HOME/.config/zsh/.zshenv"   "$HOME/.zshenv"
make_symlink "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"

# ── Taskwarrior hook permissions ──────────────────────────────────────────────
TIMEW_HOOK="$HOME/.config/task/hooks/on-modify.timewarrior"
if [[ -f "$TIMEW_HOOK" ]]; then
    chmod +x "$TIMEW_HOOK"
    success "Made $TIMEW_HOOK executable."
else
    info "Timewarrior hook not found at $TIMEW_HOOK — skipping chmod (dotfiles not yet checked out?)."
fi

# ── linux-dotfiles repo ───────────────────────────────────────────────────────
LINUX_DOTFILES="$HOME/linux-dotfiles"
if [[ -d "$LINUX_DOTFILES/.git" ]]; then
    info "linux-dotfiles already cloned. Pulling..."
    git -C "$LINUX_DOTFILES" pull
    success "linux-dotfiles updated."
else
    info "Cloning linux-dotfiles..."
    git clone git@github.com:pulkjr/linux-dotfiles.git "$LINUX_DOTFILES"
    success "linux-dotfiles cloned."
fi

# ── Shared directories ────────────────────────────────────────────────────────
for dir in "$HOME/linux-share" "$HOME/linux-local"; do
    if [[ -d "$dir" ]]; then
        success "$dir already exists. Skipping."
    else
        mkdir -p "$dir"
        success "Created $dir"
    fi
done

# ── Dev tools ─────────────────────────────────────────────────────────────────
info "Running devtools_linux.sh..."
# shellcheck source=devtools_linux.sh
source "$SCRIPT_DIR/devtools_linux.sh"

# ── pcscd for YubiKey ─────────────────────────────────────────────────────────
info "Enabling pcscd for YubiKey..."
if sudo systemctl enable --now pcscd; then
    success "pcscd enabled and started."
else
    error "Failed to enable pcscd via sudo. Run manually: sudo systemctl enable --now pcscd"
fi

# ── SSH / YubiKey FIDO2 instructions ─────────────────────────────────────────
echo -e "${YELLOW}"
echo "════════════════════════════════════════════════════════"
echo " MANUAL STEP: SSH config for YubiKey FIDO2"
echo ""
echo " Add to ~/.ssh/config:"
echo "   Host *"
echo "     SecurityKeyProvider internal"
echo "     IdentityFile ~/.ssh/id_ecdsa_sk"
echo "════════════════════════════════════════════════════════"
echo -e "${RESET}"
