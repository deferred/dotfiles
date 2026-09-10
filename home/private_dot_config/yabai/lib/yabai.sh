#!/usr/bin/env bash
# shellcheck shell=bash

# shared yabai helpers

# During a display change macOS reshuffles spaces asynchronously. While that
# happens `yabai -m query` can fail or return truncated JSON, which used to kill
# the calling script through `set -e`. These helpers retry instead.

YABAI_RETRIES="${YABAI_RETRIES:-10}"
YABAI_RETRY_DELAY="${YABAI_RETRY_DELAY:-1}"

# Run a yabai command that must print valid JSON, retrying while it fails.
# Usage: yabai_json -m query --spaces
yabai_json() {
	local attempt output
	for ((attempt = 1; attempt <= YABAI_RETRIES; attempt++)); do
		if output="$(yabai "$@" 2>/dev/null)" &&
			printf '%s' "$output" | jq -e . >/dev/null 2>&1; then
			printf '%s\n' "$output"
			return 0
		fi
		log_warn "yabai $* returned no valid JSON (attempt $attempt/$YABAI_RETRIES)"
		sleep "$YABAI_RETRY_DELAY"
	done

	log_error "yabai $* returned no valid JSON after $YABAI_RETRIES attempts"
	return 1
}

# Run a yabai command that may legitimately fail, e.g. moving a space that
# macOS has already moved. Always succeeds, so callers need no `|| true`.
# Usage: yabai_soft -m space messaging --move 6
yabai_soft() {
	yabai "$@" && return 0

	log_warn "yabai $* failed"
	return 0
}

# The current spaces as `index<TAB>display<TAB>label` lines, sorted by index.
# Every caller reads this table with plain bash instead of its own jq program.
# Label comes last because it can be empty and `read` collapses tabs.
spaces_table() {
	local payload
	payload="$(yabai_json -m query --spaces)" || return 1
	jq -r 'sort_by(.index)[] | [.index, .display, .label] | @tsv' <<<"$payload"
}
