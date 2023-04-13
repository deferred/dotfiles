#!/usr/bin/env bash

function destroy_excess_spaces {
    local num_spaces=$1
    for _ in $(yabai -m query --spaces | jq ".[].index | select(. > $num_spaces)"); do
        yabai -m space --destroy $(( $num_spaces + 1 ))
    done
}

function create_missing_spaces {
    local num_spaces=$1
    while [ $(yabai -m query --spaces | jq length) -lt $num_spaces ]; do
        yabai -m space --create
    done
}

function determine_display_index {
    local display_size=$1
    if [ "$display_size" = "l" ]; then
        echo $(yabai -m query --displays | jq 'max_by(.frame.w).index') 
    else
        echo $(yabai -m query --displays | jq 'min_by(.frame.w).index') 
    fi
}

function setup_spaces {
    local num_spaces=$1

    destroy_excess_spaces $num_spaces
    create_missing_spaces $num_spaces
    
    for i in "web 1 l" "terminal 2 l" "code 3 l" "random 4 l" "slack 5 s" "email 6 s" "teams 7 s" "telegram 8 s"; do
        # convert the "tuple" into the param args $1 $2...
        set -- $i 
        local space_label="$1"
        local space_idx="$2"
        local display_idx=$(determine_display_index $3)

        # set labels to corresponding spaces
        yabai -m space "$space_idx" --label "$space_label"

        # send spaces to corresponding displays
        echo "sending space $space_label with index $space_idx to display $display_idx"
        yabai -m space "$space_idx" --display "$display_idx"
    done
}

setup_spaces $@

