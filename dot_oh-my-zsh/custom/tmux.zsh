tsa() {
    session_name="$1"
    if [ -z "$session_name" ]; then
        echo "Usage: tmux-session <session-name>"
        return 1
    fi
    tmux attach-session -t "$session_name" 2>/dev/null || tmux new-session -s "$session_name"
}


ZSH_TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"


