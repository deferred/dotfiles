#!/usr/bin/env bash

# shellcheck source=SCRIPTDIR/lib/bootstrap.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

APP_NAME="1Password"
TARGET_SPACE="productivity"

# Main windows only: popups are non-resizable, and a floating window was put
# where it is on purpose. Given window ids, keep only those that also match.
eligible_window_ids() {
	local wanted='[]'
	[ "$#" -eq 0 ] || wanted="$(printf '%s\n' "$@" | jq -s 'map(tonumber)')"

	yabai_json -m query --windows |
		jq -r --arg app "$APP_NAME" --argjson wanted "$wanted" '
			.[]
			| select(.app == $app and ."can-resize" and (."is-floating" | not))
			| select($wanted == [] or (.id as $id | $wanted | index($id)))
			| .id
		'
}

move_1password_windows() {
	local id
	for id in $(eligible_window_ids "$@"); do
		log_info "moving window $id to space $TARGET_SPACE"
		yabai_soft -m window "$id" --space "$TARGET_SPACE"
	done
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

move_1password_windows "$@"
