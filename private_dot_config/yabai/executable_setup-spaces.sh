#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

destroy_excess_spaces() {
    local num_spaces="$1"
    echo "destroying excess spaces until there are $num_spaces"
    for _ in $(yabai -m query --spaces | jq ".[].index | select(. > $num_spaces)"); do
        echo "destroying space $((num_spaces + 1))"
        yabai -m space --destroy "$((num_spaces + 1))"
    done
}

create_missing_spaces() {
    local num_spaces=$1
    echo "creating missing spaces till there are $num_spaces"
    while [ "$(yabai -m query --spaces | jq length)" -lt "$num_spaces" ]; do
      echo "creating space"
      yabai -m space --create
    done
}

distribute_spaces_between_displays() {
    echo "distibuting spaces between displays"
    # get displays sorted by width in descending order
    local displays
    displays="$(yabai -m query --displays | jq 'sort_by(-.frame.w)')"

    local num_displays
    num_displays="$(echo "$displays" | jq 'length')"

    local num_spaces
    num_spaces="$(yabai -m query --spaces | jq 'length')"

    local spaces_per_display=$(( num_spaces / num_displays ))

    echo "found $num_displays displays and $num_spaces total spaces"
    echo "distributing spaces so each display has $spaces_per_display spaces"

    # retrieve all space information at once for faster queries
    local spaces_info
    spaces_info="$(yabai -m query --spaces)"

    local space_idx=1
    for display_idx in $(echo "$displays" | jq '.[].index'); do
        local last_space_idx=$(( space_idx + spaces_per_display - 1 ))
        while [ "$space_idx" -le "$last_space_idx" ]; do
            # get the current display of the space
            local current_display
            current_display="$(echo "$spaces_info" | jq -r '.[] | select(.index == '"$space_idx"') | .display')"

            # only move the space if it's not already on the target display
            if [ "$current_display" -eq "$display_idx" ]; then
                echo "space $space_idx is already on display $display_idx, skipping"
            else
                echo "sending space $space_idx to display $display_idx"
                yabai -m space "$space_idx" --display "$display_idx"
            fi
            (( space_idx++ ))
        done
    done

    # send excess spaces to the smallest display (last in the sorted list)
    local smallest_display_idx
    smallest_display_idx="$(echo "$displays" | jq '.[-1].index')"

    while [ "$space_idx" -le "$num_spaces" ]; do
        # get the current display of the space
        local current_display
        current_display="$(echo "$spaces_info" | jq -r '.[] | select(.index == '"$space_idx"') | .display')"

        # only move the space if it's not already on the smallest display
        if [ "$current_display" -eq "$smallest_display_idx" ]; then
            echo "space $space_idx is already on display $smallest_display_idx, skipping"
        else
            echo "sending space $space_idx to display $smallest_display_idx"
            yabai -m space "$space_idx" --display "$smallest_display_idx"
        fi
        (( space_idx++ ))
    done
}

apply_app_spaces() {
    # could not reliably use yabai -m rule --list, because spaces in rules were changing randomly
    # so even if the rule in yabairc states that Telegram should be on space 8, call to yabai -m rule --list returned space 7 for some reason
    # so hardcoding values
    apps=("Safari" "Firefox" "iTerm2" "PyCharm" "GoLand" "Insomnia" "Obsidian" "Slack" "Spark" "Microsoft Outlook" "Microsoft Teams" "Telegram" "Spotify")
    spaces=("1" "1" "2" "3" "3" "4" "4" "5" "6" "6" "7" "8" "8")

    local windows
    windows=$(yabai -m query --windows)

    # Loop through each app-space pair using array indices.
    local count=${#apps[@]}
    for (( i=0; i<count; i++ )); do
        local app="${apps[$i]}"
        local target_space="${spaces[$i]}"

        # Use jq to select window IDs where the window's app name exactly matches the app.
        local ids
        ids=$(echo "$windows" | jq -r --arg regex "^${app}\$" '.[] | select(.app | test($regex)) | .id')

        # For every matching window, move it to the desired space.
        for id in $ids; do
            echo "moving $app window $id to space $target_space"
            yabai -m window "$id" --space "$target_space"
        done
    done
}

function setup_spaces {
    local num_spaces=$1

    destroy_excess_spaces "$num_spaces"
    create_missing_spaces "$num_spaces"
    distribute_spaces_between_displays
    apply_app_spaces
}

echo "running $(basename "$0")"
setup_spaces "$@"

