#!/usr/bin/env sh

echo "Running $(basename "$0")"
focused_app=$(yabai -m query --windows --window)
is_invis_teams_noti=$(echo "$focused_app" | jq '.app == "Microsoft Teams" and .level == 3')
echo "Invisible teams window selected: $is_invis_teams_noti"

if $is_invis_teams_noti; then
        focused_display_id=$(echo "$focused_app" | jq '.display')
        visible_space_id=$(yabai -m query --spaces --display $focused_display_id | jq 'map(select(."is-visible" == true))[0].index')
	available_windows=$(yabai -m query --windows --display $focused_display_id | jq --argjson space $visible_space_id 'map(select(.space == $space))')
    yabai -m window --minimize
	recent_window_id=$(echo "$available_windows" | jq 'map(select(.title | contains("Microsoft Teams") | not))[0].id')
	yabai -m window --focus $recent_window_id
fi
