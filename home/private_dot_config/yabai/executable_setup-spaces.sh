#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=spaces
source "$(dirname "$0")/spaces"

NUM_SPACES=${#YABAI_SPACE_LABELS[@]}

destroy_excess_spaces() {
    echo "destroying excess spaces until there are $NUM_SPACES"
    for _ in $(yabai -m query --spaces | \
        jq ".[].index | select(. > $NUM_SPACES)"); do
        echo "destroying space $((NUM_SPACES + 1))"
        yabai -m space --destroy "$((NUM_SPACES + 1))"
    done
}

create_missing_spaces() {
    echo "creating missing spaces till there are $NUM_SPACES"
    while [ "$(yabai -m query --spaces | jq length)" -lt "$NUM_SPACES" ]; do
        echo "creating space"
        yabai -m space --create
    done
}

label_spaces() {
    echo "labeling spaces"
    for i in "${!YABAI_SPACE_LABELS[@]}"; do
        local index=$(( i + 1 ))
        local label="${YABAI_SPACE_LABELS[$i]}"
        echo "labeling space $index as $label"
        yabai -m space "$index" --label "$label"
    done
}

distribute_spaces_between_displays() {
    echo "distributing spaces between displays"
    # get displays sorted by width in descending order
    local displays
    displays="$(yabai -m query --displays | jq 'sort_by(-.frame.w)')"

    local num_displays
    num_displays="$(echo "$displays" | jq 'length')"

    local spaces_per_display=$(( NUM_SPACES / num_displays ))

    echo "found $num_displays displays and $NUM_SPACES total spaces"
    echo "distributing spaces so each display has $spaces_per_display spaces"

    local label_idx=0
    for display_idx in $(echo "$displays" | jq '.[].index'); do
        local last_label_idx=$(( label_idx + spaces_per_display - 1 ))
        while [ "$label_idx" -le "$last_label_idx" ]; do
            local label="${YABAI_SPACE_LABELS[$label_idx]}"

            local current_display
            current_display="$(yabai -m query --spaces --space "$label" | \
                jq -r '.display')"

            # only move the space if it's not already on the target display
            if [ "$current_display" -eq "$display_idx" ]; then
                echo "space $label is already on display $display_idx, skipping"
            else
                echo "sending space $label to display $display_idx"
                yabai -m space "$label" --display "$display_idx"
            fi
            (( label_idx++ ))
        done
    done

    # send excess spaces to the smallest display (last in the sorted list)
    local smallest_display_idx
    smallest_display_idx="$(echo "$displays" | jq '.[-1].index')"

    while [ "$label_idx" -lt "$NUM_SPACES" ]; do
        local label="${YABAI_SPACE_LABELS[$label_idx]}"

        local current_display
        current_display="$(yabai -m query --spaces --space "$label" | \
            jq -r '.display')"

        if [ "$current_display" -eq "$smallest_display_idx" ]; then
            echo "space $label is already on display $smallest_display_idx, skipping"
        else
            echo "sending space $label to display $smallest_display_idx"
            yabai -m space "$label" --display "$smallest_display_idx"
        fi
        (( label_idx++ ))
    done
}

setup_spaces() {
    destroy_excess_spaces
    create_missing_spaces
    label_spaces
    distribute_spaces_between_displays
}

echo "running $(basename "$0")"
setup_spaces
