#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$(dirname "$0")/lib/logging.sh"

# Remove all existing rules so label-to-index mappings are re-resolved
# against the current space layout.
remove_all_rules() {
	local count
	count=$(yabai -m rule --list | jq 'length')
	log_info "removing $count existing rules"
	for ((i = 0; i < count; i++)); do
		yabai -m rule --remove 0
	done
}

register_rules() {
	log_info "registering rules"

	# float non-managed apps
	yabai -m rule --add app="^Calculator$" manage=off
	yabai -m rule --add app="^Karabiner-Elements$" manage=off
	yabai -m rule --add app="^Steam$" manage=off
	yabai -m rule --add app="^Microsoft Teams$" subrole="AXSystemDialog" manage=off
	yabai -m rule --add app="^Slack$" subrole="AXSystemDialog" manage=off

	# move apps to designated spaces
	yabai -m rule --add app="^Safari$" space=^web
	yabai -m rule --add app="^Firefox$" space=^web
	yabai -m rule --add app="^Alacritty$" space=^code
	yabai -m rule --add app="^PyCharm$" space=code
	yabai -m rule --add app="^GoLand$" space=code
	yabai -m rule --add app="^Obsidian$" space=^productivity
	yabai -m rule --add app="^Things$" space=^productivity
	yabai -m rule --add app="^Slack$" space=messaging
	yabai -m rule --add app="^Microsoft Teams$" space=messaging
	yabai -m rule --add app="^Telegram$" space=messaging
	yabai -m rule --add app="^FaceTime$" space=messaging
	yabai -m rule --add app="^Spark$" space=^mail
	yabai -m rule --add app="^Microsoft Outlook$" space=mail
	yabai -m rule --add app="^Spotify$" space=^music
}

log_info "running register-rules"
remove_all_rules
register_rules
log_info "done"
