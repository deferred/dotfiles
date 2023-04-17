#!/usr/bin/env sh

function hide_teams_popup {
    local focused_window=$(yabai -m query --windows --window)
    
    local is_focused_window_teams_popup=$(echo "$focused_window" | jq '.app == "Microsoft Teams" and .level == 3')
    if $is_focused_window_teams_popup; then
        local window_id=$(echo "$focused_window" | jq '.id')
        echo "minimizing Microsoft Teams popup window $window_id" 
        yabai -m window $window_id --minimize

        local focused_display_id=$(echo "$focused_window" | jq '.display')
        local visible_space_id=$(yabai -m query --spaces --display $focused_display_id | jq 'map(select(."is-visible" == true))[0].index')
        local available_windows=$(yabai -m query --windows --display $focused_display_id | jq --argjson space $visible_space_id 'map(select(.space == $space))')
        local recent_window_id=$(echo "$available_windows" | jq 'map(select(.title | contains("Microsoft Teams") | not))[0].id // empty')
        if [[ ! -z "$recent_window_id" ]]; then
            echo "focusing window $recent_window_id instead of Microsoft Teams popup"
            yabai -m window  "$recent_window_id" --focus
        fi
    fi
}

echo "running $(basename "$0")"
hide_teams_popup $@

