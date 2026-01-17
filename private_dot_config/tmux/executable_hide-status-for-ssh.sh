#!/bin/bash

pane_ttys=$(tmux list-panes -s -F '#{pane_tty}')
ssh_found=false
for tty in $pane_ttys; do
    ps_command="ps -o comm= -t '$tty'"
    if eval "$ps_command" 2>/dev/null | grep -q -E '\<ssh\>'; then
        ssh_found=true
        break
    fi
done

if "$ssh_found"; then
    tmux set -g status off
else
    tmux set -g status on
    tmux set -g status 2 # 2 status lines
    tmux set -g status-position top
    tmux set -g status-style bg=default
    tmux set -g status-left "#[fg=blue,bold]#S  "
    tmux set -g status-left-length 32
    tmux set -g status-right ""
    tmux set -g status-format[1] '' # empty second line
fi
