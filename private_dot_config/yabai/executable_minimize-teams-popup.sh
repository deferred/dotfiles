#!/usr/bin/env sh

function minimize_teams_popup {
    local window_id=$YABAI_WINDOW_ID
    local is_teams_popup_window=$(yabai -m query --windows --window $window_id | jq '.app == "Microsoft Teams" and .frame.w == 304 and .frame.h == 247')
    if $is_teams_popup_window; then
        echo "minimizing Microsoft Teams popup window $window_id" 
        yabai -m window $window_id --minimize
        ~/.config/yabai/control-focus.sh
    fi 
}

echo "running $(basename "$0")"
minimize_teams_popup $@

