#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$script_dir/lib/logging.sh"

APP_NAME="1Password"
APP_REGEX="^1Password$"
TARGET_SPACE="productivity"

eligible_window_ids() {
	if [ "$#" -gt 0 ]; then
		local window_id
		for window_id in "$@"; do
			yabai -m query --windows --window "$window_id" 2>/dev/null |
				jq -er --arg app "$APP_NAME" '
					select(.app == $app and ."can-resize" == true and ."is-floating" == false)
					| .id
				' || true
		done
		return
	fi

	yabai -m query --windows |
		jq -r --arg app "$APP_NAME" '
			.[]
			| select(.app == $app and ."can-resize" == true and ."is-floating" == false)
			| .id
		'
}

move_1password_windows() {
	local id
	for id in $(eligible_window_ids "$@"); do
		log_info "moving window $id (matching $APP_REGEX) to space $TARGET_SPACE"
		yabai -m window "$id" --space "$TARGET_SPACE" ||
			log_warn "failed to move window $id to space $TARGET_SPACE, skipping"
	done
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

move_1password_windows "$@"
