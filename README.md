# dotfiles — macOS & Fedora Atomic Dev Environment

> Host-layer configuration for macOS (Apple Silicon / Intel) and Fedora Atomic Sway.  
> This repo lives at `~/.config` on both platforms.

---

## Two-Repo Architecture

Development config is split across two repositories:

| Repo | Mounted at | Contains |
|------|-----------|---------|
| **this repo** (`dotfiles`) | `~/.config` (host) | zsh, ghostty, tmux, yabai/skhd, sway/waybar, init scripts |
| [`linux-dotfiles`](https://github.com/pulkjr/linux-dotfiles) | `/home/dev/.config` (containers) | nvim, PowerShell, bash/bashrc, starship.toml |

The host layer handles the terminal, shell, window manager, and bootstrapping.  
The container layer handles editors and language-specific tooling — nothing is installed natively.

---

## Quick Start

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/pulkjr/dotfiles/main/init/bootstrap.sh | bash
```

### Fedora Atomic Sway

```bash
curl -fsSL https://raw.githubusercontent.com/pulkjr/dotfiles/main/init/bootstrap.sh | bash
```

> **No SSH key or YubiKey required for initial setup.** The bootstrap clones the repo
> as a bare repo to `~/.dotfiles`, checks out files into `~/.config`, then reminds
> you to switch the remote to SSH once your key is enrolled.

> **Security note:** If you prefer to inspect the script before running it:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/pulkjr/dotfiles/main/init/bootstrap.sh \
>     -o /tmp/bootstrap.sh
> # Review the script, then run:
> bash /tmp/bootstrap.sh
> ```

See [`docs/mac-setup.md`](docs/mac-setup.md) and [`docs/linux-setup.md`](docs/linux-setup.md) for full step-by-step guides.

---

## Prerequisites

### macOS
- Apple Silicon or Intel, macOS 13+
- SSH key added to GitHub
- YubiKey registered (optional but expected)
- Homebrew (installed automatically by `setup.sh` if missing)

### Fedora Atomic Sway
- Fedora Atomic Sway spin
- Podman (pre-installed)
- SSH key added to GitHub

---

## What Gets Configured

| Tool | Config path | Notes |
|------|------------|-------|
| **zsh** | `zsh/` | oh-my-zsh + Starship + zsh-vi-mode, scripts auto-loaded from `zsh/scripts/` |
| **Ghostty** | `ghostty/config` | CaskaydiaCove Nerd Font, auto-starts tmux |
| **tmux** | `tmux/` | Prefix `C-a`, modular conf.d layout, TPM plugins |
| **yabai + skhd** | `yabai/`, `skhd/` | macOS tiling WM |
| **Sway + Waybar** | `sway/`, `waybar/` | Linux WM |
| **git** | `git/config` + `git/config.local` | Global config; local identity written by `setup.sh` |
| **bat** | `bat/config` | Syntax-highlighted `cat` |
| **task / timewarrior** | `task/`, `timewarrior/` | Task and time tracking |

Container workflow (nvim, dotnet, cdev) is documented in [`docs/container-workflow.md`](docs/container-workflow.md).

---

## Keybinding Quick Reference

### App Launchers

| macOS (skhd) | Linux (Sway) | Action |
|-------------|-------------|--------|
| `cmd+ctrl+b` | `super+ctrl+b` | Browser (Chrome) |
| `cmd+ctrl+t` | `super+ctrl+t` | Terminal (Ghostty) |
| `cmd+ctrl+s` | `super+ctrl+s` | Spotify |
| `cmd+ctrl+o` | `super+ctrl+o` | Outlook |
| `cmd+ctrl+m` | `super+ctrl+m` | Teams |
| `cmd+ctrl+n` | `super+ctrl+n` | Obsidian |

### Window Management

| macOS (skhd) | Linux (Sway) | Action |
|-------------|-------------|--------|
| `alt+h/j/k/l` | `alt+h/j/k/l` | Focus window (left/down/up/right) |
| `shift+alt+h/j/k/l` | `shift+alt+h/j/k/l` | Move / swap window |
| `shift+cmd+h/j/k/l` | `super+shift+h/j/k/l` | Resize window |
| `cmd+alt+1-5` | `super+alt+1-5` | Focus space / workspace |
| `shift+cmd+1-5` | `super+shift+1-5` | Send window to space |

### tmux

| Keys | Action |
|------|--------|
| `C-a` | Prefix |
| `prefix + \|` | Split horizontal |
| `prefix + -` | Split vertical |
| `prefix + h` | Toggle status bar |

### zsh vi-mode

| Keys | Mode |
|------|------|
| `esc` | NORMAL |
| `i` | INSERT |
| `v` (in NORMAL) | Edit command in nvim |
| `/` (in NORMAL) | Search history |

---

## Updating

```bash
cd ~/.config
git pull
bash init/setup.sh
```

`setup.sh` is idempotent — safe to re-run at any time.

---

## Full Documentation

- [macOS Setup Guide](docs/mac-setup.md)
- [Linux (Fedora Atomic) Setup Guide](docs/linux-setup.md)
- [Container Workflow](docs/container-workflow.md)

---

## Contributing / Making Changes

Since `~/.config` *is* this repo, changes to config files are immediately active.  
Commit and push as you would any git repo:

```bash
cd ~/.config
git add -p          # stage selectively
git commit -m "zsh: add alias for ..."
git push
```

For container-side changes (nvim, bashrc, etc.), work in `~/linux-dotfiles` instead.
