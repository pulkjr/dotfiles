#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[setup] $*${RESET}"; }
success() { echo -e "${GREEN}[setup] $*${RESET}"; }
error()   { echo -e "${RED}[setup] $*${RESET}" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Shared: configure git local identity ─────────────────────────────────────
configure_git() {
    local config_dir="$HOME/.config/git"
    local config_file="$config_dir/config.local"

    read -r -p "Enter your Git username: " git_username
    read -r -p "Enter your Git email: " git_email

    mkdir -p "$config_dir"
    cat > "$config_file" <<EOF
[user]
  name = $git_username
  email = $git_email
EOF
    success "Git user config written to $config_file"
}

# ── Source helper: make scripts executable before sourcing ───────────────────
run_script() {
    local script="$1"
    if [[ -f "$script" ]]; then
        chmod +x "$script"
        # shellcheck disable=SC1090
        source "$script"
    else
        error "Script not found: $script"
        exit 1
    fi
}

PLATFORM="$(uname)"

# ── macOS ─────────────────────────────────────────────────────────────────────
if [[ "$PLATFORM" == "Darwin" ]]; then
    info "macOS detected."

    # 1. Xcode CLI tools
    if xcode-select -p >/dev/null 2>&1; then
        success "Xcode CLI tools already installed."
    else
        info "Xcode CLI tools not found. Launching installer..."
        xcode-select --install
        echo -e "${YELLOW}[setup] Please complete the Xcode CLI tools installation popup, then press Enter to continue.${RESET}"
        read -r
    fi

    # 2-5. macOS subscripts
    run_script "$SCRIPT_DIR/macos/brew_setup.sh"
    run_script "$SCRIPT_DIR/macos/symlinks.sh"
    run_script "$SCRIPT_DIR/macos/podman_config.sh"
    run_script "$SCRIPT_DIR/macos/devtools.sh"

    # 6. Git identity
    configure_git

    # 7-8. macOS system tweaks
    run_script "$SCRIPT_DIR/macos/defaults.sh"
    run_script "$SCRIPT_DIR/macos/swap_caps.sh"

# ── Linux ─────────────────────────────────────────────────────────────────────
elif [[ "$PLATFORM" == "Linux" ]]; then
    info "Linux detected."

    run_script "$SCRIPT_DIR/linux/setup.sh"
    configure_git

else
    error "Unsupported platform: $PLATFORM"
    exit 1
fi

# ── Post-install checklist ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}✅ Bootstrap complete! Remaining manual steps:${RESET}"
echo ""
echo -e "${YELLOW}── Bitwarden (one-time setup) ──────────────────────────────${RESET}"
echo "  [ ] Get your Bitwarden API key: https://vault.bitwarden.com/#/settings/security"
echo "  [ ] Run: bw-persist-apikey   (saves BW_CLIENTID + BW_CLIENTSECRET to macOS Keychain)"
echo "  [ ] Run: bw-persist-master   (saves master password to macOS Keychain for silent unlock)"
echo "  [ ] Run: bw-login            (first-time login using API key from Keychain)"
echo "  [ ] Run: bwu                 (unlock; session persists to ~/.bw_session)"
echo "  [ ] Store GitHub Copilot token in Bitwarden:"
echo "        bw create item  — name: 'github-copilot-token', type: Login, password: <PAT>"
echo ""
echo -e "${YELLOW}── macOS system ────────────────────────────────────────────${RESET}"
echo "  [ ] Remap Caps Lock → Escape in System Settings > Keyboard > Modifier Keys"
echo "  [ ] Grant yabai accessibility permissions in System Settings > Privacy > Accessibility"
echo "  [ ] Set Ghostty as default terminal application"
echo ""
echo -e "${YELLOW}── SSH / Git ────────────────────────────────────────────────${RESET}"
echo "  [ ] Register your YubiKey SSH key if not done: ssh-keygen -t ecdsa-sk"
echo "  [ ] Switch dotfiles remote to SSH after YubiKey is enrolled:"
echo "        dotfiles remote set-url origin git@github.com:pulkjr/dotfiles.git"
echo ""
echo -e "${YELLOW}── Containers ──────────────────────────────────────────────${RESET}"
echo "  [ ] Start minikube: minikube start --driver=podman"
