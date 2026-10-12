#!/usr/bin/env bash
# Outputs current timewarrior tracking info for the tmux status bar.
# Shows: task description + elapsed HH:MM
# Outputs nothing if timew is not installed or not tracking.

command -v timew >/dev/null 2>&1 || exit 0

active=$(timew get dom.active 2>/dev/null)
[[ "$active" != "1" ]] && exit 0

# First tag is the task description (set by the taskwarrior on-modify hook)
tag=$(timew get dom.active.tag.1 2>/dev/null)
duration=$(timew get dom.active.duration 2>/dev/null)

# Parse ISO 8601 duration PT#H#M#S into H:MM
hours=0
minutes=0
[[ "$duration" =~ ([0-9]+)H ]] && hours="${BASH_REMATCH[1]}"
[[ "$duration" =~ ([0-9]+)M ]] && minutes="${BASH_REMATCH[1]}"
elapsed=$(printf "%d:%02d" "$hours" "$minutes")

# Truncate long descriptions to keep status bar clean
max_len=28
[[ ${#tag} -gt $max_len ]] && tag="${tag:0:$max_len}…"

RESET="#[fg=brightwhite,bg=#21252b,nobold,noitalics,nounderscore,nodim]"
echo "#[fg=#e5c07b,bg=default]░  ${RESET}#[bg=default]${tag} #[fg=#56b6c2,bg=default] ${elapsed} "
