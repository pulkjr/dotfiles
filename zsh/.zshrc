if [ -z "$TMUX" ] && [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  tmux -f ~/.config/tmux/tmux.conf attach || exec tmux -f ~/.config/tmux/tmux.conf new-session
fi

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt EXTENDED_HISTORY      # record timestamp with each command
setopt SHARE_HISTORY         # share history across all sessions
setopt HIST_IGNORE_DUPS      # skip consecutive duplicate commands
setopt HIST_IGNORE_SPACE     # skip commands prefixed with a space
setopt HIST_VERIFY           # confirm before executing history expansion
setopt HIST_REDUCE_BLANKS    # trim extra whitespace from history entries

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zcompdump:h}"
compinit -d "$_zcompdump"
unset _zcompdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:git-checkout:*' sort false

# ── Directory navigation ──────────────────────────────────────────────────────
setopt AUTO_CD           # type a directory name to cd into it
setopt AUTO_PUSHD        # cd pushes old dir onto stack
setopt PUSHD_IGNORE_DUPS # no duplicate dirs in the stack

# ── Plugins ───────────────────────────────────────────────────────────────────
_zsh_plugins="$HOME/.config/zsh/plugins"

source "$_zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$_zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fzf and atuin must be (re)applied after zsh-vi-mode resets the keymap.
# Define the hook before sourcing the plugin so it is called at init time.
function zvm_after_init() {
    source <(fzf --zsh)
    eval "$(atuin init zsh --disable-up-arrow)"
}
source "$_zsh_plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
unset _zsh_plugins

# ── Load config scripts ───────────────────────────────────────────────────────
_custom_zsh_config_base="${${(%):-%x}:A:h}"

[[ ($_custom_zsh_config_base == /etc/* || ($_custom_zsh_config_base == /opt/*)) && $_custom_zsh_no_global == 1 ]] && return

if (( _custom_zsh_config_loaded )); then
	print -P '%B%F{red}The custom ZSH config is already loaded (probably from the global zshrc)%f%b'
	print -P "%B%F{red}The local version ($_custom_zsh_config_base) has NOT been loaded%f%b"
	print -P '%B%F{yellow}To disable this warning, run the following command:%f%b'
	print -P "%B%F{green}echo '_custom_zsh_no_global=1' >>! ~/.zshenv%f%b"
	return
fi
_custom_zsh_config_loaded=1

for file ($_custom_zsh_config_base/scripts/*.zsh(N)); do
	source $file
done

# ── Initialize Starship prompt (must be last) ─────────────────────────────────
eval "$(starship init zsh)"
