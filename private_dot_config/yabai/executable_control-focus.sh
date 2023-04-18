#!/usr/bin/env sh

function control_focus {
    windows=$(yabai -m query --windows --space)
    
    local teams_popup_window_id=$(echo "$windows" | jq '.[] | select(.app == "Microsoft Teams" and .frame.w == 304 and .frame.h == 247) | .id // empty')
    if [[ ! -z $teams_popup_window_id ]]; then
        echo "minimizing Microsoft Teams popup window $teams_popup_window_id" 
        yabai -m window $teams_popup_window_id --minimize
    fi 
    
    local window_id=$(echo "$windows" | jq 'map(select(.title | contains("Microsoft Teams") | not))[0].id // empty')
    if [[ ! -z $window_id ]]; then
        echo "focusing window $window_id"
        yabai -m window --focus $window_id
    fi
}

echo "running $(basename "$0")"
control_focus $@

