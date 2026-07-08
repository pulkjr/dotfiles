# dotfiles — macOS & Fedora Atomic Dev Environment

> Host-layer configuration for macOS (Apple Silicon / Intel) and Fedora Atomic Sway.  
> This repo lives at `~/.config` on both platforms, managed as a **bare git repo** at `~/.dotfiles`.

---

## Two-Repo Architecture

Development config is split across two repositories:

| Repo | Mounted at | Contains |
|------|-----------|---------|
| **this repo** (`dotfiles`) | `~/.config` (host) | zsh, ghostty, tmux, yabai/skhd, sway/waybar, init scripts |
| [`linux-dotfiles`](https://github.com/pulkjr/linux-dotfiles) | `/home/dev/.config` (containers) | nvim, PowerShell, bash/bashrc |

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
- Homebrew (installed automatically by `bootstrap.sh` if missing)

### Fedora Atomic Sway
- Fedora Atomic Sway spin
- Podman (pre-installed)
- SSH key added to GitHub

---

## What Gets Configured

| Tool | Config path | Notes |
|------|------------|-------|
| **zsh** | `zsh/` | Starship prompt, zsh-vi-mode, autosuggestions, syntax highlighting. Scripts auto-loaded from `zsh/scripts/`. Plugins managed as git clones in `~/.config/zsh/plugins/` |
| **atuin** | `atuin/config.toml` | Shell history — fuzzy search, directory-scoped `Ctrl-R`, local only (no sync) |
| **Ghostty** | `ghostty/config` | CaskaydiaCove Nerd Font, OneDark Darker theme, auto-starts tmux on launch |
| **tmux** | `tmux/` | Prefix `C-a`, vi copy mode, modular `conf.d/` layout, TPM plugins, platform-aware clipboard |
| **bat** | `bat/config` | Syntax-highlighted cat, custom OneDark Darker theme |
| **git** | `git/config` | delta pager, histogram diffs, SSH signing, rerere, per-directory identities via `includeIf` |
| **starship** | `starship/starship.toml` | OneDark palette, container image/project context, language detectors |
| **yabai + skhd** | `yabai/`, `skhd/` | macOS tiling WM, keybindings mirrored to Sway |
| **Sway + Waybar** | `sway/`, `waybar/` | Linux WM, keybindings mirrored from macOS |
| **task / timewarrior** | `task/`, `timewarrior/` | Task and time tracking, tmux status widget |
| **zk** | `zk/` | Zettelkasten note-taking, notebook at `~/projects/personal/zk` |

Container workflow (nvim, dotnet, rust, copilot, cdev) is documented in [`docs/container-workflow.md`](docs/container-workflow.md).

---

## Keybinding Quick Reference

### App Launchers

| macOS (skhd) | Linux (Sway) | Action |
|-------------|-------------|--------|
| `cmd+ctrl+b` | `super+ctrl+b` | Browser (Chrome) |
| `cmd+ctrl+t` | `super+ctrl+t` | Terminal (Ghostty) |
| `cmd+ctrl+s` | `super+ctrl+s` | Spotify |
| `cmd+ctrl+m` | `super+ctrl+m` | Outlook |
| `cmd+ctrl+c` | `super+ctrl+c` | Teams |
| `cmd+ctrl+n` | `super+ctrl+n` | Obsidian |

### Window Management

| macOS (skhd) | Linux (Sway) | Action |
|-------------|-------------|--------|
| `alt+h/j/k/l` | `alt+h/j/k/l` | Focus window (left/down/up/right) |
| `shift+alt+h/j/k/l` | `shift+alt+h/j/k/l` | Move / swap window |
| `shift+cmd+h/j/k/l` | `super+shift+h/j/k/l` | Resize window |
| `cmd+alt+1-5` | `super+alt+1-5` | Focus space / workspace |
| `shift+cmd+1-5` | `super+shift+1-5` | Send window to space |
| `ctrl+cmd+c` | `super+ctrl+c` | Move window to next display |

### tmux

| Keys | Action |
|------|--------|
| `C-a` | Prefix |
| `prefix + \|` | Split horizontal |
| `prefix + -` | Split vertical |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + S` | Toggle status bar |
| `prefix + D` | Toggle inactive pane dimming |
| `prefix + r` | Reload config |
| `Enter` | Enter copy mode |
| `y` (copy mode) | Yank to system clipboard |

### zsh

| Keys | Action |
|------|--------|
| `Ctrl-R` | Atuin fuzzy history search (directory-scoped) |
| `Ctrl-E` | Open file in nvim (from fzf) |
| `Ctrl-A` | Select all (fzf) |
| `esc` | vi NORMAL mode |
| `v` (NORMAL) | Edit command line in nvim |

---

## Updating

```bash
# Pull latest dotfiles
dotfiles pull

# Re-run setup to apply any bootstrap changes
bash ~/.config/init/setup.sh

# Update zsh and tmux plugins
zsh-update
```

`setup.sh` is idempotent — safe to re-run at any time.

---

## Full Documentation

- [macOS Setup Guide](docs/mac-setup.md)
- [Linux (Fedora Atomic) Setup Guide](docs/linux-setup.md)
- [Container Workflow](docs/container-workflow.md)

---

## Making Changes

Since `~/.config` is the work tree of the bare repo at `~/.dotfiles`, use the `dotfiles` alias for all git operations:

```bash
dotfiles status
dotfiles add -p zsh/scripts/aliases.zsh
dotfiles commit -m "zsh: add alias for ..."
dotfiles push
```

For a lazygit TUI over the dotfiles repo:

```bash
lzdot
```

For container-side changes (nvim, bashrc, etc.), work in `~/linux-dotfiles` instead.

