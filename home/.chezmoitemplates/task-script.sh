#!/usr/bin/env bash

# Run the whole calling script as one reported task.
#
# Usage, right after the shebang and `set` line of a run_ script:
#   task_script 'Label' quiet|live "$@"
#
# The script re-runs itself in a child bash, so every construct in the body
# (multi-line code, functions, pipelines, traps) behaves as usual.
#   quiet: capture output, show it only on failure
#   live:  stream output; use it for sudo prompts and installers
# DOTFILES_VERBOSE=1 forces live mode.
task_script() {
	local label="$1" mode="$2" status=0
	shift 2

	# this is the child run: continue with the script body
	if [ "${DOTFILES_TASK_CHILD:-}" = "$0" ]; then
		return 0
	fi

	if [ "$mode" = quiet ] && [ "${DOTFILES_VERBOSE:-0}" != 1 ]; then
		task_log=$(mktemp)
		trap 'rm -f "$task_log"' EXIT
		printf '%s... ' "$label" >&2
		DOTFILES_TASK_CHILD=$0 bash "$0" "$@" </dev/null >"$task_log" 2>&1 || status=$?
		if [ "$status" -eq 0 ]; then
			printf 'done\n' >&2
		else
			printf 'failed (exit %s)\n' "$status" >&2
			cat "$task_log" >&2
		fi
	else
		printf '%s...\n' "$label" >&2
		DOTFILES_TASK_CHILD=$0 bash "$0" "$@" || status=$?
		if [ "$status" -eq 0 ]; then
			printf '%s... done\n' "$label" >&2
		else
			printf '%s... failed (exit %s)\n' "$label" "$status" >&2
		fi
	fi
	exit "$status"
}
