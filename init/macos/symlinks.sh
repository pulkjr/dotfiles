#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${YELLOW}[symlinks] $*${RESET}"; }
success() { echo -e "${GREEN}[symlinks] $*${RESET}"; }
error()   { echo -e "${RED}[symlinks] $*${RESET}" >&2; }

# Usage: make_symlink <target> <link>
make_symlink() {
    local target="$1"
    local link="$2"

    # If the link already exists and is a symlink pointing to the right target, skip
    if [[ -L "$link" ]]; then
        current_target="$(readlink "$link")"
        if [[ "$current_target" == "$target" ]]; then
            success "$link → $target (already correct, skipping)"
            return
        else
            info "$link is a symlink but points to '$current_target'. Updating..."
            rm "$link"
        fi
    elif [[ -e "$link" ]]; then
        # Regular file/directory — back it up
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
