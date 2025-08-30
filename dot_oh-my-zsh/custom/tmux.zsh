tsa() {
    session_name="$1"
    if [ -z "$session_name" ]; then
        echo "Usage: tmux-session <session-name>"
        return 1
    fi
    tmux attach-session -t "$session_name" 2>/dev/null || tmux new-session -s "$session_name"
}


ZSH_TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"

# bind ctrl+alt+l to clear the screen
# uses the terminal convention where alt is sent as an esc prefix ('\e'), i.e. '\e^L' represents alt+ctrl+l
bindkey '\e^L' clear-screen

