#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

apply_app_spaces() {
    local rules
    rules=$(yabai -m rule --list)

    # extract rules that have a space assignment (space > 0)
    local app_space_pairs
    app_space_pairs=$(echo "$rules" | jq -r '.[] | select(.space > 0) | "\(.app)\t\(.space)"')

    if [[ -z "$app_space_pairs" ]]; then
        echo "warning: no app-space rules found, skipping window placement"
        return
    fi

    local windows
    windows=$(yabai -m query --windows)

    while IFS=$'\t' read -r app_regex target_space; do
        # find window IDs matching this app regex
        local ids
        ids=$(echo "$windows" | jq -r --arg regex "$app_regex" \
            '.[] | select(.app | test($regex)) | .id')

        for id in $ids; do
            echo "moving window $id (matching $app_regex) to space $target_space"
            yabai -m window "$id" --space "$target_space"
        done
    done <<< "$app_space_pairs"
}

echo "running $(basename "$0")"
apply_app_spaces
