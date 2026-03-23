#!/bin/bash
set -euo pipefail

info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Podman machine
# ---------------------------------------------------------------------------
info "Initialising Podman machine"
if podman machine inspect 2>/dev/null | grep -q '"Name"'; then
  info "Podman machine already exists — skipping init"
else
  podman machine init --cpus 4 --memory 8096 --disk-size 50 \
    || error "podman machine init failed"
  success "Podman machine initialised"
fi

# ---------------------------------------------------------------------------
# linux-dotfiles (container config repo)
# ---------------------------------------------------------------------------
if [[ -d "$HOME/linux-dotfiles/.git" ]]; then
  info "linux-dotfiles already cloned — skipping"
else
  info "Cloning linux-dotfiles"
  git clone git@github.com:pulkjr/linux-dotfiles.git "$HOME/linux-dotfiles" \
    || error "Failed to clone linux-dotfiles — check SSH keys and network"
  success "linux-dotfiles cloned to ~/linux-dotfiles"
fi

# ---------------------------------------------------------------------------
# Shared host→container directories
# ---------------------------------------------------------------------------
info "Creating shared directories"
mkdir -p "$HOME/linux-local/bin" \
         "$HOME/linux-local/share" \
         "$HOME/linux-share"
success "Shared directories ready"

