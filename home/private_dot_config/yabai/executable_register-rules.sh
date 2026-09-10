#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$script_dir/lib/logging.sh"
# shellcheck source=SCRIPTDIR/lib/yabai.sh
source "$script_dir/lib/yabai.sh"

# Remove all existing rules so label-to-index mappings are re-resolved
# against the current space layout.
remove_all_rules() {
	local count
	count=$(yabai_json -m rule --list | jq 'length')
	log_info "removing $count existing rules"
	for ((i = 0; i < count; i++)); do
		yabai_try -m rule --remove 0 || true
	done
}

# Every rule is added with yabai_try. A transient failure on one rule must not
# skip the rest, because re-registering rebuilds every label-to-index mapping.
register_rules() {
	log_info "registering rules"

	# float non-managed apps
	yabai_try -m rule --add app="^Calculator$" manage=off || true
	yabai_try -m rule --add app="^Karabiner-Elements$" manage=off || true
	yabai_try -m rule --add app="^Steam$" manage=off || true
	yabai_try -m rule --add app="^Microsoft Teams$" subrole="AXSystemDialog" manage=off || true
	yabai_try -m rule --add app="^Slack$" subrole="AXSystemDialog" manage=off || true

	# move apps to designated spaces
	yabai_try -m rule --add app="^Safari$" space=^web || true
	yabai_try -m rule --add app="^Firefox$" space=^web || true
	yabai_try -m rule --add app="^Alacritty$" space=^code || true
	yabai_try -m rule --add app="^PyCharm$" space=code || true
	yabai_try -m rule --add app="^GoLand$" space=code || true
	yabai_try -m rule --add app="^Obsidian$" space=^productivity || true
	yabai_try -m rule --add app="^Things$" space=^productivity || true
	yabai_try -m rule --add app="^Slack$" space=messaging || true
	yabai_try -m rule --add app="^Microsoft Teams$" space=messaging || true
	yabai_try -m rule --add app="^Telegram$" space=messaging || true
	yabai_try -m rule --add app="^FaceTime$" space=messaging || true
	yabai_try -m rule --add app="^Spark Desktop$" space=^mail || true
	yabai_try -m rule --add app="^Microsoft Outlook$" space=mail || true
	yabai_try -m rule --add app="^Spotify$" space=^music || true
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

enable_error_trap

log_info "running register-rules"
remove_all_rules
register_rules
log_info "done"
