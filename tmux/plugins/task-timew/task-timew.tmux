#!/usr/bin/env bash
# Local TPM-compatible plugin that appends the timewarrior/taskwarrior
# tracking widget to the status-right after tmux-onedark-theme has set it.

timew_widget="#($HOME/.config/tmux/scripts/timew-status.sh)"
tmux set -ag status-right "$timew_widget"
