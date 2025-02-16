#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

control_focus() {
  # Query all windows on the current space
  local windows
  windows="$(yabai -m query --windows --space)"

  # Extract the first window ID whose title does NOT contain "Microsoft Teams"
  local window_id
  #  1) map(...)             : Transform (map) each element of the array.
  #  2) select(...)          : Select only those items whose "title" does NOT contain "Microsoft Teams".
  #  3) [0].id               : Take the first matching item ([0]) and extract its "id".
  #  4) // ""                : If there is no item (no matching window), default to an empty string.
  window_id="$(
    jq -r '
      map(select(.title | contains("Microsoft Teams") | not))[0].id // ""
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

