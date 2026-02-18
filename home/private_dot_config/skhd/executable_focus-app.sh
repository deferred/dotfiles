#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=lib/logging.sh
source "$(dirname "$0")/lib/logging.sh"

focus_app() {
    local app="$1"

    local window_id
    window_id=$(yabai -m query --windows | jq -r ".[] | select(.app==\"$app\") | .id" | head -1)

    if [ -z "$window_id" ]; then
        log_warn "no windows found for $app"
        exit 1
    fi

    if ! yabai -m window --focus "$window_id"; then
        log_error "failed to focus window $window_id for $app"
        exit 1
    fi
}

if [ $# -eq 0 ]; then
    log_error "usage: focus-app.sh <AppName>"
    exit 1
fi

focus_app "$1"
