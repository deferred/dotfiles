#!/usr/bin/env bash
set -euo pipefail

has_processes=0
for pid in $(tmux list-panes -F "#{pane_pid}"); do
    if [ "$(pgrep -P "$pid" 2>/dev/null | wc -l)" -gt 0 ]; then
        has_processes=1
        break
    fi
done

if [ $has_processes -eq 1 ]; then
    tmux confirm-before -p "Kill window with running processes? (y/n)" kill-window || true
else
    tmux kill-window
fi
