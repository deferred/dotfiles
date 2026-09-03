#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$(dirname "$0")/lib/logging.sh"

log_info "applying space rules to existing windows"
while IFS=$'\t' read -r app space; do
	yabai -m rule --apply app="$app" space="$space" ||
		log_warn "failed to apply space $space rule for $app"
done < <(yabai -m rule --list | jq -r '.[] | select(.space > 0) | "\(.app)\t\(.space)"')

# 1Password main windows need filters that yabai rules do not support.
"$(dirname "$0")/move-1password-windows.sh"
