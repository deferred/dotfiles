#!/usr/bin/env bash

# shared logging utilities for yabai scripts

log() {
	local level="$1"
	shift
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	local script_name
	script_name=$(basename "$0")
	echo "[$timestamp] [$script_name] [$level] $*"
}

log_info() {
	log "INFO" "$@"
}

# Warnings go to stderr so they never pollute the stdout of helpers whose
# output is captured, such as yabai_json.
log_warn() {
	log "WARN" "$@" >&2
}

log_error() {
	log "ERROR" "$@" >&2
}

# Report the command that aborted the script. Without this, a failed
# `yabai -m query` under `set -e` exits silently and leaves no trace.
enable_error_trap() {
	set -E
	trap 'log_error "aborted at line $LINENO: $BASH_COMMAND (exit $?)"' ERR
}
