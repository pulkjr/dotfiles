#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[devtools] $*${RESET}"; }
success() { echo -e "${GREEN}[devtools] $*${RESET}"; }
error()   { echo -e "${RED}[devtools] $*${RESET}" >&2; }

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

# ── minikube driver config ────────────────────────────────────────────────────
if command -v minikube >/dev/null 2>&1; then
    info "Configuring minikube to use podman driver..."
    minikube config set driver podman
    success "minikube driver set to podman."

    echo ""
    echo -e "${YELLOW}Podman machine setup is required for minikube to work correctly."
    echo "This will: stop & remove any existing Podman machine, then create a new one"
    echo -e "with 4 CPUs, 8096MB RAM, 60GB disk, and start minikube.${RESET}"
    echo ""
    read -r -p "$(echo -e "${YELLOW}Set up Podman machine and start minikube now? [y/N]: ${RESET}")" setup_podman
    if [[ "$setup_podman" =~ ^[Yy]$ ]]; then
        info "Stopping and removing existing Podman machine (if any)..."
        podman machine stop 2>/dev/null || true
        podman machine rm --force 2>/dev/null || true

        info "Creating Podman machine..."
        podman machine init --cpus 4 --memory 8096 --disk-size 60
        podman machine start
        success "Podman machine started."

        info "Starting minikube..."
        minikube delete 2>/dev/null || true
        minikube start --driver=podman --container-runtime=cri-o
        success "minikube started."
    else
        echo -e "${YELLOW}"
        echo "════════════════════════════════════════════════════════"
        echo " MANUAL STEP: Podman machine + minikube setup"
        echo ""
        echo "   podman machine stop"
        echo "   podman machine rm --force"
        echo "   podman machine init --cpus 4 --memory 8096 --disk-size 60"
        echo "   podman machine start"
        echo "   minikube delete"
        echo "   minikube start --driver=podman --container-runtime=cri-o"
        echo ""
        echo "   minikube does NOT start automatically — run"
        echo "     minikube start"
        echo "   each time you need it."
        echo "════════════════════════════════════════════════════════"
        echo -e "${RESET}"
    fi
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
