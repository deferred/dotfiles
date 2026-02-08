#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Check if YABAI_WINDOW_ID is set
if [[ -z "${YABAI_WINDOW_ID:-}" ]]; then
    echo "YABAI_WINDOW_ID is not set"
    exit 1
fi

float_if_unresizable() {
    local window_id="${YABAI_WINDOW_ID}"
    
    # Check if window is resizable or already floating
    if yabai -m query --windows --window "${window_id}" | \
       jq -er '."can-resize" or ."is-floating"'; then
        # Window is resizable or already floating, do nothing
        :
    else
        # Window is not resizable and not floating, so float it
        echo "Floating unresizable window ${window_id}"
        yabai -m window "${window_id}" --toggle float
    fi
}

echo "running $(basename "$0")"
float_if_unresizable