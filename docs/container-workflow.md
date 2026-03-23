# Container Development Workflow

How development tools run in this environment and why.

---

## 1. Architecture Overview

Nothing is installed natively on the host except the shell, terminal, and window manager.  
Editors, language runtimes, and SDKs live inside Podman containers.

**Why containers?**
- No version conflicts between projects
- The host stays clean and reproducible
- Identical environment on macOS and Fedora (same container image)
- Secrets never linger in the host environment

---

## 2. Two-Repo Model

```
~/.config  (this repo — host layer)        ~/linux-dotfiles  (container layer)
├── zsh/        ← shell + functions        ├── bash/
│   └── scripts/functions.zsh             │   └── bashrc      ← container shell
├── ghostty/    ← terminal config          ├── nvim/           ← editor (all containers)
├── tmux/       ← multiplexer              ├── powershell/     ← PS config
├── sway/       ← Linux WM                 └── starship.toml   ← prompt (via mount)
├── yabai/      ← macOS WM
└── init/       ← bootstrap scripts
```

The host repo never touches editor config.  
The container repo never touches the window manager or terminal.

---

## 3. Volume Mounts

Every container launched by the zsh functions gets a consistent set of mounts:

| Host path | Container path | Purpose |
|-----------|---------------|---------|
| `$target_dir` (arg or `$PWD`) | `/projects` | Your code |
| `~/linux-dotfiles/` | `/home/dev/.config` | Container config (nvim, PS, starship) |
| `~/linux-local` | `/home/dev/.local/` | Container local binaries / data |
| `~/linux-dotfiles/bash/bashrc` | `/home/dev/.bashrc` | Container shell config |

This means nvim config, starship prompt, and shell aliases are identical across every container.

---

## 4. Container Functions

All functions live in `~/.config/zsh/scripts/functions.zsh` and are auto-loaded by `.zshrc`.

### `nvim [dir]`

Opens the `nvim-base` container with the specified directory (or `$PWD`) mounted at `/projects`.

```bash
nvim                    # open nvim in current directory
nvim ~/projects/myapp   # open nvim in a specific directory
```

Inside the container, run `nvim` as usual. All plugins and config come from `~/linux-dotfiles/nvim/`.

### `dotnet [dir]`

Opens the `dotnet` container.

```bash
dotnet                        # current directory
dotnet ~/projects/MyService   # specific project
```

The .NET SDK and runtime are inside the container — nothing is installed on the host.

### `cdev <image> [dir]`

Opens *any* container image in a new named tmux window.

```bash
cdev mycontainer                     # current dir, new tmux window named "mycontainer"
cdev rust-dev ~/projects/my-crate    # specific dir
```

Use this for ad-hoc or less common containers without writing a dedicated function.

---

## 5. tmux + Container Workflow

Ghostty launches and tmux starts automatically (or attaches to an existing session).

```
Ghostty
└── tmux session
    ├── window 1: zsh (Mac host)      ← git, brew, task, lazygit
    ├── window 2: nvim container      ← `nvim ~/projects/myapp`
    ├── window 3: dotnet container    ← `dotnet ~/projects/MyService`
    └── window 4: any container       ← `cdev rust-dev ~/projects/my-crate`
```

**Typical session:**

```bash
# Window 1 — host shell
git pull
task list

# Open a new window with nvim (prefix + c, then run:)
nvim ~/projects/myapp         # → window 2

# Open another window with dotnet
dotnet ~/projects/MyService   # → window 3
```

Navigate between windows: `C-a <window-number>` or `C-a n` / `C-a p`.

---

## 6. Secrets Management

### Unlock Bitwarden (once per session)

```bash
bwu
```

This runs `bw unlock`, captures the session key, and exports `BW_SESSION` into the current shell.  
Run it once in window 1; the session key persists for that shell.

### Inject a secret into a container call

```bash
bw-inject VAR item-name function [args...]
```

**Examples:**

```bash
# Inject a GitHub token into a dotnet container
bw-inject GITHUB_TOKEN my-github dotnet ~/projects/MyService

# Inject a registry password into an ad-hoc container
bw-inject REGISTRY_PASS my-registry cdev build-tools ~/projects/app
```

`bw-inject` looks up `item-name` in Bitwarden, stores the secret as `VAR`, then calls `function [args]` with the env var set inside the container.

`BW_SESSION` must be set (run `bwu` first). The secret is never written to disk.

---

## 7. Adding a New Container

### Step 1 — Write a Containerfile

Add it to the containers repo (`git@github.com:pulkjr/containers.git`):

```
~/containers/
└── mycontainer/
    └── Containerfile
```

### Step 2 — Build the image

```bash
podman build -t mycontainer ~/containers/mycontainer/
```

### Step 3 — Add a zsh function (optional)

For containers you use regularly, add a function to `~/.config/zsh/scripts/functions.zsh` following the existing pattern:

```zsh
mycontainer() {
  local target_dir="${1:-$PWD}"

  podman run -it --rm \
    -v "$target_dir":/projects \
    -v "$HOME/linux-dotfiles/":/home/dev/.config \
    -v "$HOME/linux-local":/home/dev/.local/ \
    -v "$HOME/linux-dotfiles/bash/bashrc":/home/dev/.bashrc \
    mycontainer
}
```

### Step 4 — Or use `cdev` for ad-hoc use

```bash
cdev mycontainer ~/projects/something
```

No function needed for one-off use.

---

## 8. Kubernetes with minikube

### Start the cluster

```bash
minikube start --driver=podman
```

### Deploy a manifest

```bash
kubectl apply -f deployment.yaml
```

### Run a pod from a Kubernetes YAML with Podman

```bash
podman play kube pod.yaml
```

### Open the dashboard

```bash
minikube dashboard
```

### Common commands

```bash
kubectl get pods -A                     # all pods
kubectl logs -f <pod-name>              # tail logs
kubectl exec -it <pod-name> -- bash     # shell into pod
minikube stop                           # stop the cluster
minikube delete                         # wipe and start fresh
```

---

## 9. Updating linux-dotfiles

Container-side changes (nvim plugins, bashrc, starship config) live in `~/linux-dotfiles`, not this repo.

```bash
cd ~/linux-dotfiles
# make changes...
git add -p
git commit -m "nvim: add plugin X"
git push
```

The changes are live immediately in new containers (the directory is mounted, not copied).  
No container rebuild needed for config-only changes.

For changes to the container image itself (new packages, base image update), rebuild:

```bash
podman build -t nvim-base ~/containers/nvim-base/
```
