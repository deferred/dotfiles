#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

minimize_teams_popup() {
  local window_id="${YABAI_WINDOW_ID}"
  local is_teams_popup_window

  is_teams_popup_window="$(yabai -m query --windows --window "${window_id}" \
      | jq '.app == "Microsoft Teams"
            and (.frame.w == 304 or .frame.w == 192)
            and .["is-minimized"] == false')"

  if [[ "${is_teams_popup_window}" == "true" ]]; then
      echo "minimizing Microsoft Teams popup window ${window_id}"
      yabai -m window "${window_id}" --minimize
  fi
}

echo "running $(basename "$0")"
minimize_teams_popup
