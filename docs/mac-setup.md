# macOS Setup Guide

Full setup guide for the macOS host environment (Apple Silicon or Intel).

---

## 1. Prerequisites

- macOS 13 Ventura or later (Apple Silicon or Intel)
- SSH key generated and added to GitHub
- YubiKey registered with your GitHub account (optional but expected)
- Internet connection

Homebrew does **not** need to be installed in advance — `setup.sh` will install it if missing.

---

## 2. Clone the Repo

```bash
git clone git@github.com:<USERNAME>/dotfiles.git ~/.config
```

> This places the dotfiles at `~/.config`, which is the XDG config base directory used by all tools in this setup.

---

## 3. Run Bootstrap

```bash
cd ~/.config/init
bash setup.sh
```

### What `setup.sh` Does

#### Phase 1 — Podman / Docker alias
If `podman` is installed, creates a symlink `docker → podman` so tools that expect `docker` work transparently.

#### Phase 2 — Git identity
Prompts for your name and email, then writes them to `~/.config/git/config.local`:
```ini
[user]
  name  = Your Name
  email = you@example.com
```
The global `~/.config/git/config` includes this file, so it's picked up everywhere.

#### Phase 3 — macOS defaults (`macos/defaults.sh`)
Applies opinionated system defaults:
- Dock: autohide with zero delay, no animations, show only running apps, hide recent apps
- Finder: list view, show extensions, show path bar
- Keyboard: fast key repeat (delay 12 / repeat 2), press-and-hold disabled, Tab navigation enabled
- Menu bar: auto-hide
- Mission Control: group windows by app, disable separate spaces per display

#### Phase 4 — Podman machine (`macos/podman_config.sh`)
- Initialises a Podman machine: `podman machine init --cpus 4 --memory 8096 --disk-size 50`
- Clones `linux-dotfiles` to `~/linux-dotfiles` (container config layer)
- Creates `~/linux-share` shared directory

#### Phase 5 — Caps Lock reminder (`macos/swap_caps.sh`)
Prints a reminder to remap Caps Lock to Escape (must be done manually — see post-install steps).

---

## 4. Post-Install Manual Steps

Complete these after `setup.sh` finishes:

1. **Bitwarden login**
   ```bash
   bw login
   bwu          # unlock and export BW_SESSION
   ```

2. **Remap Caps Lock → Escape**  
   System Settings → **Keyboard** → **Keyboard Shortcuts…** → **Modifier Keys**  
   Set *Caps Lock (⇪) Key* to **Escape**. Click Done.

3. **Grant yabai Accessibility access**  
   System Settings → **Privacy & Security** → **Accessibility**  
   Click **+** and add `/usr/local/bin/yabai` (or wherever `which yabai` points).  
   Restart yabai: `yabai --restart-service`

4. **Set Ghostty as default terminal**  
   Right-click any `.sh` or `.command` file in Finder → **Open With** → **Other…** → select Ghostty → tick **Always Open With**.  
   Or set it as the default terminal app in iTerm-style apps if prompted.

5. **YubiKey SSH key** (if not already done)
   ```bash
   ssh-keygen -t ecdsa-sk -f ~/.ssh/id_ecdsa_sk
   # Add the public key to GitHub:
   cat ~/.ssh/id_ecdsa_sk.pub | pbcopy
   # Paste at github.com > Settings > SSH and GPG keys
   ```

6. **Start Podman machine and minikube**
   ```bash
   podman machine start
   minikube start --driver=podman
   ```

7. **Install Homebrew packages** (if not already done by `setup.sh`)
   ```bash
   brew bundle --file ~/.config/Brewfile
   ```

8. **Install tmux plugins**
   Start tmux, then press `prefix + I` (`C-a I`) to install plugins via TPM.

9. **oh-my-zsh + plugins**  
   If not present, install oh-my-zsh:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```
   Then install the custom plugins referenced in `.zshrc`:
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions \
     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting \
     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   ```

---

## 5. Updating the Environment

```bash
cd ~/.config
git pull
bash init/setup.sh
```

`setup.sh` is safe to re-run — it skips steps that are already done (e.g., the Podman symlink, existing git config).

For Homebrew packages:
```bash
brew bundle --file ~/.config/Brewfile
```

---

## 6. Troubleshooting

### yabai is not tiling windows

- Check accessibility permission: System Settings → Privacy & Security → Accessibility → confirm yabai is listed and enabled.
- Check yabai is running: `yabai --list-rules` or `brew services list | grep yabai`
- Check logs: `cat /tmp/yabai_<username>.out.log`
- Restart: `yabai --restart-service && skhd --restart-service`

### tmux plugins not loading (TPM)

- Ensure TPM is cloned:
  ```bash
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  ```
- Inside tmux, run `prefix + I` to install plugins.
- If `run-shell` fails, check the path in `tmux.conf` matches your actual TPM location.

### Bitwarden session expired

```bash
bwu    # re-unlock; exports a fresh BW_SESSION to the current shell
```

`BW_SESSION` is per-shell. If you open a new terminal or tmux window, run `bwu` again, or pass the session explicitly.

### Ghostty not auto-starting tmux

The tmux auto-start line in `.zshrc` is commented out by default:
```zsh
#if [ -z "$TMUX" ] && [ "$TERM" = "xterm-ghostty" ]; then
#  tmux -f ~/.config/tmux/tmux.conf attach || exec tmux -f ~/.config/tmux/tmux.conf new-session
#fi
```
Uncomment it to enable auto-attach on Ghostty launch.

### Podman machine won't start

```bash
podman machine stop   # stop if in a bad state
podman machine rm     # remove and re-init if needed
podman machine init --cpus 4 --memory 8096 --disk-size 50
podman machine start
```
