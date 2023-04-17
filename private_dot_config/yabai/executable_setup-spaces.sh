#!/usr/bin/env bash

function destroy_excess_spaces {
    local num_spaces=$1
    echo "destroying excess spacess till there are $num_spaces"
    for _ in $(yabai -m query --spaces | jq ".[].index | select(. > $num_spaces)"); do
        yabai -m space --destroy $(( $num_spaces + 1 ))
    done
}

function create_missing_spaces {
    local num_spaces=$1
    echo "creating missing spaces till there are $num_spaces"
    while [ $(yabai -m query --spaces | jq length) -lt $num_spaces ]; do
        yabai -m space --create
    done
}

function distribute_spaces_between_displays {
    # get displays sorted by width in descending order
    local displays=$(yabai -m query --displays | jq 'sort_by(-.frame.w)')

    local num_displays=$(echo $displays | jq 'length')
    local num_spaces=$( yabai -m query --spaces | jq 'length' )
    local spaces_per_display=$(( $num_spaces / $num_displays ))

    echo "distributing spaces between displays so there are $spaces_per_display spaces on each display"
    local space_idx=1
    for display_idx in $(echo $displays | jq '.[].index'); do
        local last_space_idx=$(( $space_idx + $spaces_per_display - 1))
        while [ $space_idx -le $last_space_idx ]; do
            echo "sending space $space_idx to display $display_idx"
            yabai -m space "$space_idx" --display "$display_idx"
            ((space_idx++))
        done
    done
    
    # send excess spaces to the smallest display
    local smallest_display_idx=$(echo $displays | jq '.[-1]')
    while [ $space_idx -lt $num_spaces ]; do
        echo "sending space $space_idx to display $smallest_display_idx"
        yabai -m space "$space_idx" --display "$smallest_display_idx"
        ((space_idx++))
    done
}

function setup_spaces {
    local num_spaces=$1

    destroy_excess_spaces $num_spaces
    create_missing_spaces $num_spaces
    distribute_spaces_between_displays
}

echo "running $(basename "$0")"
setup_spaces $@

