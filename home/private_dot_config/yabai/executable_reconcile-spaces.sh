#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$script_dir/lib/logging.sh"
# shellcheck source=SCRIPTDIR/lib/yabai.sh
source "$script_dir/lib/yabai.sh"

# macOS sets TMPDIR with a trailing slash, most other systems do not. Strip it
# so the runtime paths are the same string everywhere.
runtime_dir="${TMPDIR:-/tmp}"
runtime_dir="${runtime_dir%/}"
lock_dir="$runtime_dir/yabai-reconcile.lock.d"
pending_file="$runtime_dir/yabai-reconcile.pending"

RECONCILE_MAX_RUNS="${RECONCILE_MAX_RUNS:-5}"
LAYOUT_STABLE_READS="${LAYOUT_STABLE_READS:-30}"

# A cap below one would skip the loop and reconcile nothing at all.
[ "$RECONCILE_MAX_RUNS" -ge 1 ] 2>/dev/null || RECONCILE_MAX_RUNS=1

# Take the lock, or ask the running reconciliation to repeat once it finishes.
# Dropping the second event outright used to lose the retry that recovered from
# a failed first pass.
acquire_lock_or_queue() {
	drop_stale_lock

	if mkdir "$lock_dir" 2>/dev/null; then
		echo "$$" >"$lock_dir/pid"
		trap 'rm -rf "$lock_dir"' EXIT
		return 0
	fi

	log_info "reconciliation already running, queueing a rerun"
	touch "$pending_file"
	return 1
}

drop_stale_lock() {
	[ -d "$lock_dir" ] || return 0

	# Ignore a lock that was just created; its owner may not have written its
	# pid yet.
	[ -z "$(find "$lock_dir" -maxdepth 0 -mmin -1)" ] || return 0

	local pid
	pid="$(cat "$lock_dir/pid" 2>/dev/null || true)"
	if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
		return 0
	fi

	log_warn "removing stale lock from pid ${pid:-unknown}"
	rm -rf "$lock_dir"
}

# macOS keeps rearranging spaces for a while after a display event. Wait until
# two consecutive reads agree instead of guessing with a fixed sleep.
wait_for_stable_layout() {
	local attempt previous="" current

	for ((attempt = 1; attempt <= LAYOUT_STABLE_READS; attempt++)); do
		current="$(yabai_json -m query --displays | jq -cS 'map({index, uuid, frame})')" || return 1
		current+="$(yabai_json -m query --spaces | jq -cS 'map({index, label, display})')" || return 1

		if [ "$current" = "$previous" ]; then
			log_info "layout stable after $attempt reads"
			return 0
		fi

		previous="$current"
		sleep 1
	done

	log_warn "layout still changing, reconciling anyway"
	return 0
}

# Run every step even if an earlier one fails. Re-applying the rules matters
# most, and it used to be skipped whenever space setup hit a transient error.
reconcile_once() {
	local status=0

	wait_for_stable_layout

	"$script_dir/setup-spaces.sh" || {
		status=1
		log_error "setup-spaces.sh failed, continuing"
	}
	"$script_dir/register-rules.sh" || {
		status=1
		log_error "register-rules.sh failed, continuing"
	}
	"$script_dir/apply-app-spaces.sh" || {
		status=1
		log_error "apply-app-spaces.sh failed"
	}

	return "$status"
}

main() {
	acquire_lock_or_queue || exit 0

	local status=0 run
	# The cap stops a storm of display events from looping forever.
	for ((run = 1; run <= RECONCILE_MAX_RUNS; run++)); do
		rm -f "$pending_file"
		reconcile_once || status=1
		[ -e "$pending_file" ] || return "$status"

		if [ "$run" -eq "$RECONCILE_MAX_RUNS" ]; then
			log_warn "reached $RECONCILE_MAX_RUNS reconciliations, dropping queued events"
			rm -f "$pending_file"
			return "$status"
		fi

		log_info "rerunning reconciliation for a queued display event"
	done
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

main
