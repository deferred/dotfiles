#!/usr/bin/env bash
# Kill zsh processes orphaned from a previous tmux server (ppid=1).
# Called by tmux-resurrect pre-restore hook to prevent shell accumulation.
ps -eo pid,ppid,comm | awk '$2 == 1 && $3 == "-zsh" { print $1 }' | xargs kill -9 2>/dev/null || true
pkill -9 -P 1 -f gitstatusd 2>/dev/null || true
