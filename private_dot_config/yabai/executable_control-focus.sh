#!/usr/bin/env sh

function control_focus {
    local window_id=$(yabai -m query --windows --space | jq 'map(select(.title | contains("Microsoft Teams") | not))[0].id // empty')
    if [[ ! -z $window_id ]]; then
        echo "focusing window $window_id"
        yabai -m window --focus $window_id
    fi
}

echo "running $(basename "$0")"
control_focus $@

