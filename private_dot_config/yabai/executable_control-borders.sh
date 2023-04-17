#!/usr/bin/env bash

function control_window_borders {
    local multiple_windows_visible=$(yabai -m query --windows --space | jq 'map(select(."is-visible" == true)) | length > 1')
    if $multiple_windows_visible
    then
        echo "turning window border on because multiple windows are visible on focused space"
        yabai -m config window_border on
        yabai -m config window_border_hidpi on
        yabai -m config window_border_width 2
        yabai -m config active_window_border_color "0xFF50FA7B"
        # transparent
        yabai -m config normal_window_border_color "0x00FFFFFF"
    else
        echo "turning window border off"
        yabai -m config window_border off
    fi
}

echo "running $(basename "$0")"
control_window_borders $@
