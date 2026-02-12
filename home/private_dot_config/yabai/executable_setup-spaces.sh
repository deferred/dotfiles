#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=spaces
source "$(dirname "$0")/spaces"

NUM_SPACES=${#YABAI_SPACE_LABELS[@]}

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

destroy_excess_spaces() {
    log "destroying excess spaces until there are $NUM_SPACES"
    for _ in $(yabai -m query --spaces | \
        jq ".[].index | select(. > $NUM_SPACES)"); do
        log "destroying space $((NUM_SPACES + 1))"
        yabai -m space --destroy "$((NUM_SPACES + 1))"
    done
}

create_missing_spaces() {
    log "creating missing spaces until there are $NUM_SPACES"
    while [ "$(yabai -m query --spaces | jq length)" -lt "$NUM_SPACES" ]; do
        log "creating space"
        yabai -m space --create
    done
}

label_spaces() {
    log "labeling spaces"
    for i in "${!YABAI_SPACE_LABELS[@]}"; do
        local index=$(( i + 1 ))
        local label="${YABAI_SPACE_LABELS[$i]}"
        log "labeling space $index as $label"
        yabai -m space "$index" --label "$label"
    done
}

distribute_spaces_between_displays() {
    log "distributing spaces between displays"

    # small delay to ensure display is fully registered
    log "waiting 0.5s for display registration..."
    sleep 0.5

    # get displays sorted by width in descending order
    local displays
    displays="$(yabai -m query --displays | jq 'sort_by(-.frame.w)')"

    local num_displays
    num_displays="$(echo "$displays" | jq 'length')"

    log "found $num_displays displays:"
    echo "$displays" | jq -r '.[] | "  display \(.index): \(.frame.w)x\(.frame.h)"'

    if [ "$num_displays" -eq 0 ]; then
        log "error: no displays found"
        return 1
    fi

    local spaces_per_display=$(( NUM_SPACES / num_displays ))

    log "distributing $NUM_SPACES spaces so each display has ~$spaces_per_display spaces"

    local label_idx=0
    for display_idx in $(echo "$displays" | jq '.[].index'); do
        local last_label_idx=$(( label_idx + spaces_per_display - 1 ))
        log "assigning spaces to display $display_idx (labels $label_idx-$last_label_idx)"

        while [ "$label_idx" -le "$last_label_idx" ]; do
            local label="${YABAI_SPACE_LABELS[$label_idx]}"

            local current_display
            current_display="$(yabai -m query --spaces --space "$label" | \
                jq -r '.display')"

            log "  space '$label': currently on display $current_display, target display $display_idx"

            # only move the space if it's not already on the target display
            if [ "$current_display" -eq "$display_idx" ]; then
                log "    -> already on target, skipping"
            else
                log "    -> moving to display $display_idx"
                if yabai -m space "$label" --display "$display_idx"; then
                    log "    -> success"
                else
                    log "    -> failed to move space '$label'"
                fi
            fi
            label_idx=$((label_idx + 1))
        done
    done

    # send excess spaces to the smallest display (last in the sorted list)
    local smallest_display_idx
    smallest_display_idx="$(echo "$displays" | jq '.[-1].index')"

    if [ "$label_idx" -lt "$NUM_SPACES" ]; then
        log "assigning remaining spaces to smallest display $smallest_display_idx"
    fi

    while [ "$label_idx" -lt "$NUM_SPACES" ]; do
        local label="${YABAI_SPACE_LABELS[$label_idx]}"

        local current_display
        current_display="$(yabai -m query --spaces --space "$label" | \
            jq -r '.display')"

        log "  space '$label': currently on display $current_display, target display $smallest_display_idx"

        if [ "$current_display" -eq "$smallest_display_idx" ]; then
            log "    -> already on target, skipping"
        else
            log "    -> moving to display $smallest_display_idx"
            if yabai -m space "$label" --display "$smallest_display_idx"; then
                log "    -> success"
            else
                log "    -> failed to move space '$label'"
            fi
        fi
        label_idx=$((label_idx + 1))
    done

    # validate final state
    log "validating final space distribution..."
    local validation_failed=0
    for i in "${!YABAI_SPACE_LABELS[@]}"; do
        local label="${YABAI_SPACE_LABELS[$i]}"
        local space_info
        space_info="$(yabai -m query --spaces --space "$label" 2>/dev/null || echo '{}')"
        local display
        display="$(echo "$space_info" | jq -r '.display // "unknown"')"
        log "  space '$label' is on display $display"
    done
}

setup_spaces() {
    destroy_excess_spaces
    create_missing_spaces
    label_spaces
    distribute_spaces_between_displays
}

log "running $(basename "$0")"
setup_spaces
log "done"
