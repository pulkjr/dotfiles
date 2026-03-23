#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[devtools-linux] $*${RESET}"; }
success() { echo -e "${GREEN}[devtools-linux] $*${RESET}"; }
error()   { echo -e "${RED}[devtools-linux] $*${RESET}" >&2; }

# ── TPM (tmux plugin manager) ────────────────────────────────────────────────
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
TMUX_CONF="$HOME/.config/tmux/tmux.conf"

if [[ -d "$TPM_DIR/.git" ]]; then
    info "TPM already cloned. Pulling latest..."
    git -C "$TPM_DIR" pull
    success "TPM updated."
else
    info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    success "TPM cloned."
fi

# TPM needs a running tmux server to read plugin list — start a headless session
info "Starting headless tmux session for TPM..."
tmux -f "$TMUX_CONF" new-session -d -s _tpm_setup_ 2>/dev/null || true

info "Installing TPM plugins..."
TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
    "$TPM_DIR/bin/install_plugins" && success "TPM plugins installed."

info "Updating TPM plugins..."
TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
    "$TPM_DIR/bin/update_plugins" all && success "TPM plugins updated."

tmux kill-session -t _tpm_setup_ 2>/dev/null || true

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
OMZ_DIR="$HOME/.config/zsh/oh-my-zsh"
if [[ -d "$OMZ_DIR" ]]; then
    success "oh-my-zsh already installed at $OMZ_DIR. Skipping."
else
    info "Installing oh-my-zsh..."
    ZSH="$OMZ_DIR" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "oh-my-zsh installed."
fi

# ── zsh plugins ──────────────────────────────────────────────────────────────
PLUGINS_DIR="$HOME/.config/zsh/oh-my-zsh/custom/plugins"
mkdir -p "$PLUGINS_DIR"

clone_plugin() {
    local repo="$1"
    local name
    name="$(basename "$repo" .git)"
    local dest="$PLUGINS_DIR/$name"
    if [[ -d "$dest/.git" ]]; then
        success "Plugin '$name' already cloned. Skipping."
    else
        info "Cloning plugin '$name'..."
        git clone "$repo" "$dest"
        success "Plugin '$name' cloned."
    fi
}

clone_plugin https://github.com/zsh-users/zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git
clone_plugin https://github.com/jeffreytse/zsh-vi-mode

# ── Starship prompt ───────────────────────────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
    success "Starship already installed: $(starship --version | head -1)"
else
    info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    success "Starship installed."
fi

# ── minikube driver config ────────────────────────────────────────────────────
if command -v minikube >/dev/null 2>&1; then
    info "Configuring minikube to use podman driver..."
    minikube config set driver podman
    success "minikube driver set to podman."
    echo -e "${YELLOW}"
    echo "════════════════════════════════════════════════════════"
    echo " NOTE: minikube driver config"
    echo "   On first setup (or after changing drivers), run:"
    echo "     minikube delete && minikube start"
    echo "   minikube does NOT start automatically — run"
    echo "     minikube start"
    echo "   each time you need it."
    echo "════════════════════════════════════════════════════════"
    echo -e "${RESET}"
else
    info "minikube not installed. Skipping driver config."
fi

# ── containers repo ───────────────────────────────────────────────────────────
CONTAINERS_DIR="$HOME/containers"
if [[ -d "$CONTAINERS_DIR/.git" ]]; then
    info "containers repo already cloned. Pulling..."
    git -C "$CONTAINERS_DIR" pull
    success "containers repo updated."
else
    info "Cloning containers repo..."
    if git clone git@github.com:pulkjr/containers.git "$CONTAINERS_DIR"; then
        success "containers repo cloned."
    else
        error "Failed to clone containers repo (SSH key may not be available). Skipping."
    fi
fi

# ── pcscd for YubiKey ─────────────────────────────────────────────────────────
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    info "Enabling pcscd for YubiKey..."
    sudo systemctl enable --now pcscd
    success "pcscd enabled."
else
    echo -e "${YELLOW}"
    echo "════════════════════════════════════════════════════════"
    echo " MANUAL STEP: YubiKey pcscd"
    echo "   Run: sudo systemctl enable --now pcscd"
    echo "════════════════════════════════════════════════════════"
    echo -e "${RESET}"
fi

# ── linux-dotfiles repo ───────────────────────────────────────────────────────
LINUX_DOTFILES_DIR="$HOME/linux-dotfiles"
if [[ -d "$LINUX_DOTFILES_DIR/.git" ]]; then
    info "linux-dotfiles repo already cloned. Pulling..."
    git -C "$LINUX_DOTFILES_DIR" pull
    success "linux-dotfiles repo updated."
else
    info "Cloning linux-dotfiles repo..."
    if git clone git@github.com:pulkjr/linux-dotfiles.git "$LINUX_DOTFILES_DIR"; then
        success "linux-dotfiles repo cloned."
    else
        error "Failed to clone linux-dotfiles repo (SSH key may not be available). Skipping."
    fi
fi

# ── Seed bash/bashrc into linux-dotfiles ─────────────────────────────────────
BASHRC_SRC="$HOME/.config/bash/bashrc"
BASHRC_DEST="$HOME/linux-dotfiles/bash/bashrc"
if [[ -f "$BASHRC_SRC" && -d "$HOME/linux-dotfiles" ]]; then
    if [[ ! -f "$BASHRC_DEST" ]]; then
        mkdir -p "$HOME/linux-dotfiles/bash"
        cp "$BASHRC_SRC" "$BASHRC_DEST"
        success "Seeded bash/bashrc into linux-dotfiles. Commit it when ready."
    else
        info "linux-dotfiles/bash/bashrc already exists — skipping seed."
    fi
fi

# ── Manual Bitwarden step ─────────────────────────────────────────────────────
echo -e "${YELLOW}"
echo "════════════════════════════════════════════════════════"
echo " MANUAL STEP: Bitwarden"
echo "   Run 'bw login' to authenticate with Bitwarden,"
echo "   then 'bwu' to unlock and export BW_SESSION"
echo "════════════════════════════════════════════════════════"
echo -e "${RESET}"
