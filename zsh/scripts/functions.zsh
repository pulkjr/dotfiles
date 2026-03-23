# A nice look of the git log
# The gll Bash alias displays a compact Git log list that can be filtered by entering a fuzzy term at the prompt.
# Navigation up and down the commit list will preview the changes of each commit.
# https://bluz71.github.io/2018/11/26/fuzzy-finding-in-bash-with-fzf.html
fzf_git_log() {
	local selections=$(
		git log --graph --format="%C(yellow)%h%C(red)%d%C(reset) - %C(bold green)(%ar)%C(reset) %s %C(blue)<%an>%C(reset)" --color=always "$@" |
			fzf --ansi --no-sort --no-height \
				--preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                       xargs -I@ sh -c 'git show --color=always @'"
	)
	if [[ -n $selections ]]; then
		local commits=$(echo "$selections" | sed 's/^[* |]*//' | cut -d' ' -f1 | tr '\n' ' ')
		git show $commits
	fi
}

alias gll='fzf_git_log'

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Fuzzy find a directory, with optional initial directory name, and then change to it:
# - If one directory matches then cd immediately
# - If multiple directories match, or no directory name is provided, then open fzf with tree preview
# - If no directories match then exit immediately
# https://bluz71.github.io/2018/11/26/fuzzy-finding-in-bash-with-fzf.html
fzf_change_directory() {
	local directory=$(
		find . -type d | grep -v '.git' |
			fzf --query="$1" --no-multi --select-1 --exit-0 \
				--preview 'tree -C {} | head -100'
	)
	if [[ -n $directory ]]; then
		cd "$directory"
	fi
}

alias fcd='fzf_change_directory'

fzf_open_file() {
	local code_file=$(
		find . -type f | grep -v '.git' |
			fzf --query="$1" --no-multi --select-1 --exit-0 \
				--preview 'bat --style numbers,changes --color always {} | head -200'
	)
	# Prefer code-insiders, fall back to code
	if command -v code-insiders &>/dev/null; then
		code-insiders "$code_file"
	elif command -v code &>/dev/null; then
		code "$code_file"
	else
		echo "fcode: neither code-insiders nor code found in PATH" >&2
		return 1
	fi
}

alias fcode='fzf_open_file'

# setup zoxide
eval "$(zoxide init zsh --cmd cd)"

# Validate that container bind-mount directories exist
# Usage: _container_dirs_ok  (returns 1 and prints error if missing)
_container_dirs_ok() {
  local ok=0
  if [[ ! -d "$HOME/linux-dotfiles" ]]; then
    echo "container: ~/linux-dotfiles not found — run podman_config.sh first" >&2
    ok=1
  fi
  if [[ ! -d "$HOME/linux-local" ]]; then
    echo "container: ~/linux-local not found — run podman_config.sh first" >&2
    ok=1
  fi
  return $ok
}

# Enter the nvim-base container for editing
# Usage: nvim [directory]  — defaults to current directory
nvim() {
  _container_dirs_ok || return 1
  local target_dir="${1:-$PWD}"
  podman run -it --rm \
    -v "$target_dir":/projects \
    -v "$HOME/linux-dotfiles/":/home/dev/.config \
    -v "$HOME/linux-local":/home/dev/.local/ \
    -v "$HOME/linux-dotfiles/bash/bashrc":/home/dev/.bashrc \
    nvim-base nvim .
}

# Open any container image in a new named tmux window (or standalone if not in tmux)
# Usage: cdev <image> [directory]
cdev() {
  _container_dirs_ok || return 1
  local image="${1:?Usage: cdev <image> [dir]}"
  local target_dir="${2:-$PWD}"
  local window_name="${image##*/}"   # strip registry prefix for window name
  local run_cmd="podman run -it --rm \
    -v '$target_dir':/projects \
    -v '$HOME/linux-dotfiles/':/home/dev/.config \
    -v '$HOME/linux-local':/home/dev/.local/ \
    -v '$HOME/linux-dotfiles/bash/bashrc':/home/dev/.bashrc \
    $image"
  if tmux has-session 2>/dev/null; then
    tmux new-window -n "$window_name" "$run_cmd"
  else
    eval "$run_cmd"
  fi
}

# ── Bitwarden helpers ──────────────────────────────────────────────────────────

# One-time setup: save your Bitwarden master password to macOS Keychain.
# Run this once on a new machine; bwu will use it silently from then on.
#   Usage: bw-persist-master
bw-persist-master() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "bw-persist-master: macOS Keychain only (Darwin). On Linux, store credentials another way."
    return 1
  fi
  local pw
  echo -n "Enter Bitwarden master password to store in Keychain: "
  read -rs pw; echo
  security add-generic-password -U -s "bitwarden-master" -a "$USER" -w "$pw" \
    && echo "Master password saved to Keychain under service 'bitwarden-master'." \
    || { echo "Keychain write failed."; return 1; }
}

# One-time setup: save Bitwarden API key credentials to macOS Keychain.
#
# Where to find your API key:
#   1. Go to: https://vault.bitwarden.com
#   2. Click your avatar (top-right) → Account Settings → Security → API Key
#   3. Click "View API Key" and authenticate
#   4. Copy the values shown:
#        Client ID:     user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#        Client Secret: a short alphanumeric string (e.g. xxXXxxxxXXxx)
#
#   Usage: bw-persist-apikey
bw-persist-apikey() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "bw-persist-apikey: macOS Keychain only (Darwin)."
    return 1
  fi
  echo ""
  echo "Bitwarden API Key setup"
  echo "──────────────────────────────────────────────────────────────"
  echo "  1. Open: https://vault.bitwarden.com"
  echo "  2. Avatar (top-right) → Account Settings → Security → API Key"
  echo "  3. Click 'View API Key' and authenticate with your master password"
  echo "  4. You will see:"
  echo "       client_id:     user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  echo "       client_secret: a short alphanumeric string"
  echo "──────────────────────────────────────────────────────────────"
  echo ""
  local client_id client_secret
  echo -n "Paste client_id (user.xxxx-...): "
  read -r client_id
  echo -n "Paste client_secret: "
  read -rs client_secret; echo
  security add-generic-password -U -s "bitwarden-clientid"     -a "$USER" -w "$client_id"     && \
  security add-generic-password -U -s "bitwarden-clientsecret" -a "$USER" -w "$client_secret" && \
    echo "API key credentials saved to Keychain." \
    || { echo "Keychain write failed."; return 1; }
}

# Login to Bitwarden using API key credentials stored in macOS Keychain.
# Run once on a new machine after bw-persist-apikey.
# Safe to run again — skips gracefully if already logged in.
#   Usage: bw-login
bw-login() {
  # If already logged in, no need to login again — just remind user to run bwu
  if bw login --check &>/dev/null; then
    echo "Already logged in to Bitwarden. Run 'bwu' to unlock and export BW_SESSION."
    return 0
  fi

  if [[ "$(uname)" == "Darwin" ]]; then
    local client_id client_secret
    client_id="$(security find-generic-password -w -s "bitwarden-clientid" -a "$USER" 2>/dev/null)" \
      || { echo "bw-login: BW_CLIENTID not in Keychain. Run: bw-persist-apikey"; return 1; }
    client_secret="$(security find-generic-password -w -s "bitwarden-clientsecret" -a "$USER" 2>/dev/null)" \
      || { echo "bw-login: BW_CLIENTSECRET not in Keychain. Run: bw-persist-apikey"; return 1; }
    BW_CLIENTID="$client_id" BW_CLIENTSECRET="$client_secret" bw login --apikey \
      && echo "Bitwarden logged in via API key. Now run: bwu" \
      || { echo "bw login --apikey failed. Re-run bw-persist-apikey to update your credentials."; return 1; }
  else
    bw login
  fi
}

# Unlock Bitwarden and export session token.
# On macOS, tries master password from Keychain first (silent unlock).
# Persists session to ~/.bw_session so new shells auto-load it (see exports.zsh).
#   Usage: bwu
bwu() {
  local session

  if [[ "$(uname)" == "Darwin" ]]; then
    local pw
    pw="$(security find-generic-password -w -s "bitwarden-master" -a "$USER" 2>/dev/null)"
    if [[ -n "$pw" ]]; then
      session="$(BW_PASSWORD="$pw" bw unlock --passwordenv BW_PASSWORD --raw 2>/dev/null)" \
        || session=""
    fi
  fi

  if [[ -z "$session" ]]; then
    session="$(bw unlock --raw)" || { echo "bw unlock failed — are you logged in? Run: bw-login"; return 1; }
  fi

  export BW_SESSION="$session"
  # Persist so new shells pick it up automatically via exports.zsh
  printf '%s' "$session" > "$HOME/.bw_session"
  chmod 600 "$HOME/.bw_session"
  echo "Bitwarden unlocked. BW_SESSION exported and persisted to ~/.bw_session."
}

# Inject a Bitwarden secret as an env var into a container function call
# Usage: bw-inject VAR_NAME bw-item-name <container-function> [function-args...]
# Example: bw-inject GITHUB_TOKEN my-gh-token dotnet /path/to/project
bw-inject() {
  local var_name="${1:?Usage: bw-inject VAR_NAME item-name func [args]}"
  local item_name="${2:?}"
  shift 2
  local value
  value="$(bw get password "$item_name" 2>/dev/null)" \
    || { echo "bw-inject: failed to get secret '$item_name' — is BW_SESSION set? Run bwu first."; return 1; }
  env "${var_name}=${value}" "$@"
}

# Enter a dotnet container
dotnet() {
  _container_dirs_ok || return 1
  local target_dir="${1:-$PWD}"
  podman run -it --rm \
    -v "$target_dir":/projects \
    -v "$HOME/linux-dotfiles/":/home/dev/.config \
    -v "$HOME/linux-local":/home/dev/.local/ \
    -v "$HOME/linux-dotfiles/bash/bashrc":/home/dev/.bashrc \
    dotnet
}
# One-time setup: store your GitHub Personal Access Token in Bitwarden.
# The copilot() function reads this token automatically when you launch the container.
#
# ⚠️  GitHub Copilot requires a Fine-Grained PAT — classic PATs (ghp_) are NOT supported.
#
# Where to get a Fine-Grained PAT:
#   1. Go to: https://github.com/settings/tokens?type=beta
#   2. Click "Generate new token"
#   3. Token name: e.g. "copilot-cli"
#   4. Expiration: your preference
#   5. Resource owner: your account
#   6. Repository access: "Public Repositories (read-only)" is sufficient
#   7. No extra permissions needed — click "Generate token"
#   8. Copy the token (starts with github_pat_)
#
# Alternatively, if you have the gh CLI installed and authenticated:
#   gh auth login   (run once, uses browser OAuth — no token to manage)
#   gh auth token   (prints the stored token you can paste below)
#
# Requires: bwu must have been run first (BW_SESSION must be set)
#   Usage: copilot-store-token
copilot-store-token() {
  if [[ -z "${BW_SESSION:-}" ]]; then
    echo "copilot-store-token: BW_SESSION not set. Run 'bwu' first to unlock Bitwarden."
    return 1
  fi
  echo ""
  echo "GitHub Fine-Grained PAT setup for Copilot"
  echo "──────────────────────────────────────────────────────────────"
  echo "  ⚠️  Classic PATs (ghp_) are NOT supported — use a fine-grained PAT."
  echo ""
  echo "  Option A — Create a Fine-Grained PAT manually:"
  echo "    1. Open: https://github.com/settings/tokens?type=beta"
  echo "    2. Click 'Generate new token'"
  echo "    3. Set resource owner to your account, any expiration"
  echo "    4. Repository access: 'Public Repositories (read-only)' is enough"
  echo "    5. Generate — token starts with github_pat_"
  echo ""
  echo "  Option B — Use gh CLI (if already authenticated via gh auth login):"
  echo "    Run: gh auth token   (then paste the output below)"
  echo "──────────────────────────────────────────────────────────────"
  echo ""
  local token
  echo -n "Paste your Fine-Grained PAT (github_pat_...): "
  read -rs token; echo
  [[ -z "$token" ]] && { echo "No token entered. Aborted."; return 1; }

  if ! command -v jq &>/dev/null; then
    echo "copilot-store-token: 'jq' not found. Install it: brew install jq"; return 1
  fi

  local item_json
  item_json="$(bw get template item | jq --arg t "$token" \
    '.type=1 | .name="github-copilot-token" | .login={password:$t}')"

  echo "$item_json" | bw encode | bw create item > /dev/null \
    && echo "✅ Token stored in Bitwarden as 'github-copilot-token'. You can now run: copilot" \
    || { echo "Failed to create Bitwarden item. Ensure BW_SESSION is valid (run bwu)."; return 1; }
}

# Enter the copilot container
# Injects GH_TOKEN from env (if set) or fetches it from Bitwarden item 'github-copilot-token'.
# Prerequisites: run bwu first so BW_SESSION is set, or export GH_TOKEN manually.
#   Usage: copilot [directory]
copilot() {
  _container_dirs_ok || return 1
  local target_dir="${1:-$PWD}"

  local gh_token="${GH_TOKEN:-}"

  if [[ -z "$gh_token" ]]; then
    if [[ -z "${BW_SESSION:-}" ]]; then
      echo "copilot: GH_TOKEN not set and BW_SESSION not found."
      echo "  Option 1: export GH_TOKEN=<your-github-pat>"
      echo "  Option 2: run 'bwu' first, then store your token in Bitwarden as 'github-copilot-token'"
      return 1
    fi
    gh_token="$(bw get password github-copilot-token 2>/dev/null)" \
      || { echo "copilot: 'github-copilot-token' not found in Bitwarden. Run: copilot-store-token"; return 1; }
  fi

  podman run -it --rm \
    -e GH_TOKEN="$gh_token" \
    -v "$target_dir":/projects \
    -v "$HOME/linux-dotfiles/":/home/dev/.config \
    -v "$HOME/linux-dotfiles/bash/bashrc":/home/dev/.bashrc \
    localhost/copilot
}
