if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
  tmux attach || exec tmux new-session && exit;
fi
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="steeef"
#"af-magic"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="yyyy-mm-dd"

plugins=(
    git
    gitfast
    dotnet
    docker
    docker-compose
    macos
    tmux
    zsh-autosuggestions
    zsh-syntax-highlighting
    )

source $ZSH/oh-my-zsh.sh

# Commenting these for a time to see if their needed.
# autoload -U +X bashcompinit && bashcompinit
# complete -o nospace -C /usr/local/bin/terraform terraform
# autoload -Uz compinit
# compinit

# Load all of the sub resources in ~/.zshrc.d/*.zsh
# get the directory where this file is located
_custom_zsh_config_base="${${(%):-%x}:A:h}"

# bail out if global config is disabled
[[ ($_custom_zsh_config_base == /etc/* || ($_custom_zsh_config_base == /opt/*)) && $_custom_zsh_no_global == 1 ]] && return

# bail out if we are already loaded
if (( _custom_zsh_config_loaded )); then
	print -P '%B%F{red}The custom ZSH config is already loaded (probably from the global zshrc)%f%b'
	print -P "%B%F{red}The local version ($_custom_zsh_config_base) has NOT been loaded%f%b"
	print -P '%B%F{yellow}To disable this warning, run the following command:%f%b'
	print -P "%B%F{green}echo '_custom_zsh_no_global=1' >>! ~/.zshenv%f%b"
	return
fi
_custom_zsh_config_loaded=1

# load all our config files
for file ($_custom_zsh_config_base/.zshrc.d/*.zsh(N)); do
	source $file
done

export PATH="$(brew --prefix)/opt/node@18/bin:$(brew --prefix)/opt/llvm/bin:/Users/jpulk/Library/Python/3.11/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
