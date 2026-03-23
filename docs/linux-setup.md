# Fedora Atomic Sway Setup Guide

Full setup guide for the Fedora Atomic Sway host environment.

---

## 1. Prerequisites

- Fedora Atomic Sway spin (or Fedora Silverblue with Sway layered)
- Podman pre-installed (included in Fedora Atomic)
- SSH key generated and added to GitHub
- YubiKey (optional but expected for FIDO2 SSH)

---

## 2. Clone the Repo

```bash
git clone git@github.com:<USERNAME>/dotfiles.git ~/.config
```

> `~/.config` is the XDG config base directory. All tools (zsh, tmux, ghostty, sway, etc.) read their config from here automatically.

---

## 3. Run Bootstrap

```bash
cd ~/.config/init
bash setup.sh
```

### What the Linux Bootstrap Does

`setup.sh` detects a non-Darwin OS and runs the Linux-specific path:

#### Git identity
Prompts for name and email, writes to `~/.config/git/config.local`.

#### Podman / Docker alias
If `podman` is installed, symlinks `docker → podman`.

#### rpm-ostree packages
Layers additional packages on the immutable base image (reboot required to activate):
```bash
rpm-ostree install \
  zsh tmux ghostty \
  sway waybar \
  fzf ripgrep eza bat zoxide \
  htop ncdu lazygit \
  yubikey-manager pcscd \
  minikube kubectl
```

#### Flatpak apps
Installs user-scoped Flatpak apps (Flathub):
- Spotify, Microsoft Teams, Obsidian, (others as configured)

#### oh-my-zsh
Installs oh-my-zsh plus `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins.

#### linux-dotfiles
Clones `git@github.com:pulkjr/linux-dotfiles.git` to `~/linux-dotfiles` (container config layer).

#### minikube
Configures minikube to use the Podman driver.

---

## 4. YubiKey FIDO2 SSH Setup

### Enable the smart-card daemon

```bash
sudo systemctl enable --now pcscd
```

### Verify YubiKey is detected

```bash
ykman info
```

Expected output shows device type, serial number, and enabled features.

### Generate FIDO2 SSH key (if not already done)

```bash
ssh-keygen -t ecdsa-sk -f ~/.ssh/id_ecdsa_sk
```

Touch the YubiKey when prompted.

### Add to SSH config

```
# ~/.ssh/config
Host github.com
  IdentityFile ~/.ssh/id_ecdsa_sk
  IdentitiesOnly yes
```

### Add public key to GitHub

```bash
cat ~/.ssh/id_ecdsa_sk.pub
# Paste at github.com > Settings > SSH and GPG keys
```

---

## 5. Post-Install Manual Steps

1. **Reboot** to activate rpm-ostree layered packages:
   ```bash
   systemctl reboot
   ```

2. **Set zsh as default shell** (after reboot, if not already set):
   ```bash
   chsh -s $(which zsh)
   ```

3. **Install tmux plugins**  
   Start tmux, then press `C-a I` to install plugins via TPM.  
   If TPM is not cloned:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
   ```

4. **Bitwarden login**
   ```bash
   bw login
   bwu          # unlock and export BW_SESSION
   ```

5. **Start minikube**
   ```bash
   minikube start --driver=podman
   ```

6. **Log into Flatpak apps**  
   Launch Spotify, Teams, and any other Flatpak apps and sign in.

7. **Clone linux-dotfiles** (if `setup.sh` didn't do it):
   ```bash
   git clone git@github.com:pulkjr/linux-dotfiles.git ~/linux-dotfiles
   mkdir -p ~/linux-local
   ```

---

## 6. Sway Keybinding Reference

> Modifier key: `super` (Win/Cmd key)

### App Launchers

| Binding | Action |
|---------|--------|
| `super+ctrl+b` | Browser (Chrome) |
| `super+ctrl+t` | Terminal (Ghostty) |
| `super+ctrl+s` | Spotify |
| `super+ctrl+o` | Outlook |
| `super+ctrl+m` | Teams |
| `super+ctrl+n` | Obsidian |

### Window Focus

| Binding | Action |
|---------|--------|
| `alt+h` | Focus left |
| `alt+l` | Focus right |
| `alt+k` | Focus up |
| `alt+j` | Focus down |

### Window Move / Swap

| Binding | Action |
|---------|--------|
| `shift+alt+h` | Move / swap left |
| `shift+alt+l` | Move / swap right |
| `shift+alt+k` | Warp up |
| `shift+alt+j` | Warp down |

### Window Resize

| Binding | Action |
|---------|--------|
| `super+shift+h` | Resize left |
| `super+shift+l` | Resize right |
| `super+shift+k` | Resize up |
| `super+shift+j` | Resize down |

### Workspaces

| Binding | Action |
|---------|--------|
| `super+alt+1-5` | Focus workspace 1–5 |
| `super+shift+1-5` | Send focused window to workspace 1–5 |

### System

| Binding | Action |
|---------|--------|
| `super+shift+q` | Close focused window |
| `super+shift+e` | Exit Sway |
| `super+shift+r` | Reload Sway config |
| `super+f` | Toggle fullscreen |
| `super+space` | Toggle floating |

---

## 7. Updating the Environment

```bash
cd ~/.config
git pull
bash init/setup.sh
```

For new system packages:
```bash
rpm-ostree upgrade        # update base image
rpm-ostree install <pkg>  # layer new packages
systemctl reboot
```

For Flatpak apps:
```bash
flatpak update
```
