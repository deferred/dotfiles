#!/usr/bin/env bash

# shellcheck source=SCRIPTDIR/lib/bootstrap.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

# Rules only fire for new windows, so existing windows need the rules applied
# by hand. This is the step that rescues a window stranded on another display.
apply_app_spaces() {
	log_info "applying space rules to existing windows"

	local rules app space
	rules="$(yabai_json -m rule --list)" || return 1

	while IFS=$'\t' read -r app space; do
		log_info "applying space $space to $app"
		yabai_soft -m rule --apply app="$app" space="$space"
	done < <(jq -r '.[] | select(.space > 0) | "\(.app)\t\(.space)"' <<<"$rules")
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

apply_app_spaces

# 1Password main windows need filters that yabai rules do not support.
"$yabai_dir/move-1password-windows.sh"
