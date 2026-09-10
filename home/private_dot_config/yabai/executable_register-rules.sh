#!/usr/bin/env bash

# shellcheck source=SCRIPTDIR/lib/bootstrap.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

# Remove all existing rules so label-to-index mappings are re-resolved
# against the current space layout.
remove_all_rules() {
	local count index
	count="$(yabai_json -m rule --list | jq 'length')" || return 1

	log_info "removing $count existing rules"
	for ((index = 0; index < count; index++)); do
		yabai_soft -m rule --remove 0
	done
}

# Keep a window unmanaged. Pass a subrole to target only that kind of window.
float_app() {
	local app="$1" subrole="${2:-}"
	if [ -n "$subrole" ]; then
		yabai_soft -m rule --add app="$app" subrole="$subrole" manage=off
	else
		yabai_soft -m rule --add app="$app" manage=off
	fi
}

# Send a window to a space by label. yabai resolves the label to an index at
# registration time, which is why every display change re-registers.
send_app() { yabai_soft -m rule --add app="$1" space="$2"; }

# Every rule is added with yabai_soft. A transient failure on one rule must not
# skip the rest, because re-registering rebuilds every label-to-index mapping.
register_rules() {
	log_info "registering rules"

	float_app '^Calculator$'
	float_app '^Karabiner-Elements$'
	float_app '^Steam$'
	float_app '^Microsoft Teams$' 'AXSystemDialog'
	float_app '^Slack$' 'AXSystemDialog'

	send_app '^Safari$' '^web'
	send_app '^Firefox$' '^web'
	send_app '^Alacritty$' '^code'
	send_app '^PyCharm$' 'code'
	send_app '^GoLand$' 'code'
	send_app '^Obsidian$' '^productivity'
	send_app '^Things$' '^productivity'
	send_app '^Slack$' 'messaging'
	send_app '^Microsoft Teams$' 'messaging'
	send_app '^Telegram$' 'messaging'
	send_app '^FaceTime$' 'messaging'
	send_app '^Spark Desktop$' '^mail'
	send_app '^Microsoft Outlook$' 'mail'
	send_app '^Spotify$' '^music'
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

log_info "running register-rules"
remove_all_rules || log_error "could not remove existing rules, continuing"
register_rules
log_info "done"
