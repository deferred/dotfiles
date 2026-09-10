#!/usr/bin/env bash

# shellcheck source=SCRIPTDIR/lib/bootstrap.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

# macOS sets TMPDIR with a trailing slash, most other systems do not. Strip it
# so the runtime path is the same string everywhere.
runtime_dir="${TMPDIR:-/tmp}"
pidfile="${runtime_dir%/}/yabai-reconcile.pid"

LAYOUT_STABLE_READS="${LAYOUT_STABLE_READS:-30}"

wait_for_exit() {
	local pid="$1" attempt
	for ((attempt = 0; attempt < 30; attempt++)); do
		kill -0 "$pid" 2>/dev/null || return 0
		sleep 0.1
	done
	log_warn "reconciliation $pid did not exit"
}

# Reconciliation is idempotent, so the newest display event wins: cancel the
# run in flight and start over with fresh state.
claim_run() {
	local pid
	pid="$(cat "$pidfile" 2>/dev/null || true)"
	if [ -n "$pid" ] && [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null; then
		log_info "cancelled reconciliation $pid"
		wait_for_exit "$pid"
	fi

	echo "$$" >"$pidfile"
	trap 'rm -f "$pidfile"' EXIT
}

layout_fingerprint() {
	yabai_json -m query --displays | jq -cS 'map({index, uuid, frame})' || return 1
	spaces_table || return 1
}

# macOS keeps rearranging spaces for a while after a display event. Wait until
# two consecutive reads agree instead of guessing with a fixed sleep.
wait_for_stable_layout() {
	local attempt previous="" current
	for ((attempt = 1; attempt <= LAYOUT_STABLE_READS; attempt++)); do
		current="$(layout_fingerprint)" || return 0

		if [ "$current" = "$previous" ]; then
			log_info "layout stable after $attempt reads"
			return 0
		fi

		previous="$current"
		sleep 1
	done

	log_warn "layout still changing, reconciling anyway"
}

# Run every step even if an earlier one fails. Re-applying the rules matters
# most, and it used to be skipped whenever space setup hit a transient error.
reconcile_once() {
	local status=0

	"$yabai_dir/setup-spaces.sh" || {
		status=1
		log_error "setup-spaces.sh failed, continuing"
	}
	"$yabai_dir/register-rules.sh" || {
		status=1
		log_error "register-rules.sh failed, continuing"
	}
	"$yabai_dir/apply-app-spaces.sh" || {
		status=1
		log_error "apply-app-spaces.sh failed"
	}

	return "$status"
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

claim_run
wait_for_stable_layout
reconcile_once
