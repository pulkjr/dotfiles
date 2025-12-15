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
	code-insiders $code_file
}

alias fcode='fzf_open_file'

# setup zoxide
eval "$(zoxide init zsh --cmd cd)"

# Run neofetch
# neofetch

# Open vscode
# code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

