#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$script_dir/lib/logging.sh"
# shellcheck source=SCRIPTDIR/lib/yabai.sh
source "$script_dir/lib/yabai.sh"

apply_app_spaces() {
	log_info "applying space rules to existing windows"

	local rules app space
	rules="$(yabai_json -m rule --list)" || return 1

	while IFS=$'\t' read -r app space; do
		log_info "applying space $space to $app"
		yabai_try -m rule --apply app="$app" space="$space" || true
	done < <(echo "$rules" | jq -r '.[] | select(.space > 0) | "\(.app)\t\(.space)"')
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

enable_error_trap

apply_app_spaces

# 1Password main windows need filters that yabai rules do not support.
"$script_dir/move-1password-windows.sh"
