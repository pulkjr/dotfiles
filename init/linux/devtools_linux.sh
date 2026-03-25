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
    if git -C "$TPM_DIR" pull; then
        success "TPM updated."
    else
        error "Failed to pull TPM (network/SSH issue). Skipping."
    fi
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
# Use git clone instead of curl|sh: HTTPS transport provides integrity, avoids
# piping untrusted remote scripts directly into a shell.
OMZ_DIR="$HOME/.config/zsh/oh-my-zsh"
if [[ -d "$OMZ_DIR" ]]; then
    success "oh-my-zsh already installed at $OMZ_DIR. Skipping."
else
    info "Installing oh-my-zsh via git clone..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
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
# Version is pinned for supply chain safety. To upgrade:
#   1. Check https://github.com/starship/starship/releases for the new tag
#   2. Update STARSHIP_VERSION below
#   3. Verify the sha256sums file from the release page against a trusted source
STARSHIP_VERSION="v1.22.1"

install_starship_verified() {
    local arch tarball base tmp

    case "$(uname -m)" in
        x86_64)          arch="x86_64-unknown-linux-musl" ;;
        aarch64 | arm64) arch="aarch64-unknown-linux-musl" ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac

    tarball="starship-${arch}.tar.gz"
    base="https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}"
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' RETURN

    info "Downloading Starship ${STARSHIP_VERSION} (${tarball})..."
    curl -fsSL "${base}/${tarball}"  -o "${tmp}/${tarball}"
    curl -fsSL "${base}/sha256sums"  -o "${tmp}/sha256sums"

    info "Verifying SHA256 checksum..."
    if ! grep -F "${tarball}" "${tmp}/sha256sums" | (cd "${tmp}" && sha256sum --check --status); then
        error "Starship checksum verification FAILED. Aborting installation."
        return 1
    fi
    success "Checksum verified."

    tar -xzf "${tmp}/${tarball}" -C "${tmp}"
    sudo install -m 755 "${tmp}/starship" /usr/local/bin/starship
}

if command -v starship >/dev/null 2>&1; then
    success "Starship already installed: $(starship --version | head -1)"
else
    info "Installing Starship ${STARSHIP_VERSION}..."
    install_starship_verified
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
    if git -C "$CONTAINERS_DIR" pull; then
        success "containers repo updated."
    else
        error "Failed to pull containers repo (network/SSH issue). Skipping."
    fi
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
    if git -C "$LINUX_DOTFILES_DIR" pull; then
        success "linux-dotfiles repo updated."
    else
        error "Failed to pull linux-dotfiles repo (network/SSH issue). Skipping."
    fi
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
