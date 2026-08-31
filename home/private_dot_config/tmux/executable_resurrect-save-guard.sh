#!/usr/bin/env bash

save_script="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"
lock_file="${TMPDIR:-/tmp}/tmux-resurrect-save-${UID}.lock"

log_error() {
	if command -v logger >/dev/null 2>&1; then
		logger -t tmux-resurrect-save -- "$*"
	else
		printf 'tmux-resurrect-save: %s\n' "$*" >&2
	fi
}

if [[ ! -x "$save_script" ]]; then
	log_error "save script is not executable: $save_script"
	exit 127
fi

declare -a locker
case "$(uname -s)" in
Darwin)
	locker=(/usr/bin/lockf -s -t 0 -k "$lock_file")
	;;
Linux)
	if ! flock_path="$(command -v flock)"; then
		log_error "flock is not installed (install util-linux)"
		exit 127
	fi
	locker=("$flock_path" -n -E 75 "$lock_file")
	;;
*)
	log_error "unsupported operating system: $(uname -s)"
	exit 127
	;;
esac

"${locker[@]}" nice -n 10 "$save_script" "$@"
status=$?

# A save already holds the lock; skipping this autosave is expected.
[[ "$status" -eq 75 ]] && exit 0

if [[ "$status" -ne 0 ]]; then
	log_error "save failed with status $status"
fi

exit "$status"
