#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

control_focus() {
  # Query all windows on the current space
  local windows
  windows="$(yabai -m query --windows --space)"

  # Extract the first visible window ID that is not Microsoft Teams or Slack
  local window_id
  window_id="$(
    jq -r '
      map(
        select(
          .app != "Microsoft Teams" and
          .app != "Slack" and
          .["is-hidden"] == false
        )
      )[0].id // ""
    ' <<< "$windows"
  )"

  # If a valid window ID was found, focus it
  if [[ -n "$window_id" ]]; then
    echo "focusing window $window_id"
    yabai -m window --focus "$window_id"
  else
    echo "no suitable window found to focus"
  fi
}

echo "running $(basename "$0")"
control_focus

