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

# ── Shared: configure git identities ─────────────────────────────────────────
# Writes three gitignored identity files:
#   ~/.config/git/config.local       — default fallback for all repos
#   ~/projects/work/.gitconfig       — work identity (via includeIf in git/config)
#   ~/projects/personal/.gitconfig   — personal identity (via includeIf in git/config)
#
# Idempotent: each file is only written if it does not already exist.
# Re-running setup.sh on a configured machine skips any file already present.
configure_git() {
    local config_dir="$HOME/.config/git"
    local work_dir="$HOME/projects/work"
    local personal_dir="$HOME/projects/personal"
    mkdir -p "$config_dir" "$work_dir" "$personal_dir"

    local need_default=false need_work=false need_personal=false need_key=false

    [[ ! -f "$config_dir/config.local"   ]] && need_default=true
    [[ ! -f "$work_dir/.gitconfig"       ]] && need_work=true
    [[ ! -f "$personal_dir/.gitconfig"   ]] && need_personal=true

    # Nothing to do
    if ! $need_default && ! $need_work && ! $need_personal; then
        success "Git identities already configured — skipping."
        success "  default  → $config_dir/config.local"
        success "  work     → $work_dir/.gitconfig"
        success "  personal → $personal_dir/.gitconfig"
        return
    fi

    echo ""
    info "── Git identities ───────────────────────────────────────────"
    info "These files are gitignored and never committed."
    info "Skipping any identity file that already exists."
    echo ""

    # ── SSH key — shared by work and personal (one YubiKey) ──────────────────
    # Only prompt if at least one identity file needs writing
    if $need_work || $need_personal; then
        need_key=true
    fi

    local _ssh_pubkey_path="" _ssh_pubkey=""
    if $need_key; then
        read -r -p "  SSH public key file (e.g. ~/.ssh/id_ed25519_sk.pub): " _ssh_pubkey_path
        _ssh_pubkey_path="${_ssh_pubkey_path/#\~/$HOME}"
        if [[ -f "$_ssh_pubkey_path" ]]; then
            _ssh_pubkey="$(cat "$_ssh_pubkey_path")"
        else
            error "Key file not found: $_ssh_pubkey_path — signingKey will need to be set manually."
        fi
    fi

    # ── Default (fallback) identity ───────────────────────────────────────────
    if $need_default; then
        info "Default identity (fallback for repos outside work/ and personal/):"
        read -r -p "  Name  : " _default_name
        read -r -p "  Email : " _default_email
        cat > "$config_dir/config.local" <<EOF
[user]
  name = ${_default_name}
  email = ${_default_email}
EOF
        success "Default identity → $config_dir/config.local"
    else
        success "Default identity already exists — skipping."
    fi

    # ── Work identity ─────────────────────────────────────────────────────────
    if $need_work; then
        echo ""
        info "Work identity (repos under ~/projects/work/):"
        read -r -p "  Name  : " _work_name
        read -r -p "  Email : " _work_email
        cat > "$work_dir/.gitconfig" <<EOF
[user]
  name = ${_work_name}
  email = ${_work_email}
  signingKey = ${_ssh_pubkey_path}
[gpg]
  format = ssh
# TODO: once your corporate S/MIME code-signing cert is issued, replace the
# [gpg] block above with:
#   [gpg]
#     format = x509
#   [gpg "x509"]
#     program = smimesign
# and remove the signingKey line — smimesign reads the cert from Keychain automatically.
EOF
        success "Work identity → $work_dir/.gitconfig"
    else
        success "Work identity already exists — skipping."
    fi

    # ── Personal identity ─────────────────────────────────────────────────────
    if $need_personal; then
        echo ""
        info "Personal identity (repos under ~/projects/personal/):"
        read -r -p "  Name  : " _personal_name
        read -r -p "  Email : " _personal_email
        cat > "$personal_dir/.gitconfig" <<EOF
[user]
  name = ${_personal_name}
  email = ${_personal_email}
  signingKey = ${_ssh_pubkey_path}
[gpg]
  format = ssh
EOF
        success "Personal identity → $personal_dir/.gitconfig"
    else
        success "Personal identity already exists — skipping."
    fi

    # ── allowed_signers — append new entries, skip duplicates ────────────────
    local signers_file="$config_dir/allowed_signers"
    touch "$signers_file"
    if [[ -n "$_ssh_pubkey" ]]; then
        for _entry in "${_work_email:-} ${_ssh_pubkey}" "${_personal_email:-} ${_ssh_pubkey}"; do
            if [[ -n "${_entry// }" ]] && ! grep -qF "$_ssh_pubkey" "$signers_file" 2>/dev/null; then
                echo "$_entry" >> "$signers_file"
            fi
        done
        success "allowed_signers → $signers_file"
    fi
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
