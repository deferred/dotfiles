#!/usr/bin/env bash
set -euo pipefail

# shared logging utilities for skhd scripts

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

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@" >&2
}
