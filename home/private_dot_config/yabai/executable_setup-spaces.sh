#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=spaces
source "$(dirname "$0")/spaces"
# shellcheck source=lib/logging.sh
source "$(dirname "$0")/lib/logging.sh"

NUM_SPACES=${#YABAI_SPACE_LABELS[@]}

destroy_excess_spaces() {
    log_info "destroying excess spaces until there are $NUM_SPACES"
    for _ in $(yabai -m query --spaces | \
        jq ".[].index | select(. > $NUM_SPACES)"); do
        log_info "destroying space $((NUM_SPACES + 1))"
        yabai -m space --destroy "$((NUM_SPACES + 1))"
    done
}

create_missing_spaces() {
    log_info "creating missing spaces until there are $NUM_SPACES"
    while [ "$(yabai -m query --spaces | jq length)" -lt "$NUM_SPACES" ]; do
        log_info "creating space"
        yabai -m space --create
    done
}

label_spaces() {
    log_info "labeling spaces"
    for i in "${!YABAI_SPACE_LABELS[@]}"; do
        local index=$(( i + 1 ))
        local label="${YABAI_SPACE_LABELS[$i]}"
        log_info "labeling space $index as $label"
        yabai -m space "$index" --label "$label"
    done
}

distribute_spaces_between_displays() {
    log_info "distributing spaces between displays"

    # small delay to ensure display is fully registered
    log_info "waiting 0.5s for display registration..."
    sleep 0.5

    # get displays sorted by width in descending order
    local displays
    displays="$(yabai -m query --displays | jq 'sort_by(-.frame.w)')"

    local num_displays
    num_displays="$(echo "$displays" | jq 'length')"

    log_info "found $num_displays displays:"
    echo "$displays" | jq -r '.[] | "  display \(.index): \(.frame.w)x\(.frame.h)"'

    if [ "$num_displays" -eq 0 ]; then
        log_error "no displays found"
        return 1
    fi

    local spaces_per_display=$(( NUM_SPACES / num_displays ))

    log_info "distributing $NUM_SPACES spaces so each display has ~$spaces_per_display spaces"

    local label_idx=0
    for display_idx in $(echo "$displays" | jq '.[].index'); do
        local last_label_idx=$(( label_idx + spaces_per_display - 1 ))
        log_info "assigning spaces to display $display_idx (labels $label_idx-$last_label_idx)"

        while [ "$label_idx" -le "$last_label_idx" ]; do
            local label="${YABAI_SPACE_LABELS[$label_idx]}"

            local current_display
            current_display="$(yabai -m query --spaces --space "$label" | \
                jq -r '.display')"

            log_info "  space '$label': currently on display $current_display, target display $display_idx"

            # only move the space if it's not already on the target display
            if [ "$current_display" -eq "$display_idx" ]; then
                log_info "    space '$label' already on display $display_idx, skipping"
            else
                log_info "    moving space '$label' to display $display_idx"
                if yabai -m space "$label" --display "$display_idx"; then
                    log_info "    successfully moved space '$label' to display $display_idx"
                else
                    log_error "    failed to move space '$label' to display $display_idx"
                fi
            fi
            label_idx=$((label_idx + 1))
        done
    done

    # send excess spaces to the smallest display (last in the sorted list)
    local smallest_display_idx
    smallest_display_idx="$(echo "$displays" | jq '.[-1].index')"

    if [ "$label_idx" -lt "$NUM_SPACES" ]; then
        log_info "assigning remaining spaces to smallest display $smallest_display_idx"
    fi

    while [ "$label_idx" -lt "$NUM_SPACES" ]; do
        local label="${YABAI_SPACE_LABELS[$label_idx]}"

        local current_display
        current_display="$(yabai -m query --spaces --space "$label" | \
            jq -r '.display')"

            log_info "  space '$label': currently on display $current_display, target display $smallest_display_idx"

        if [ "$current_display" -eq "$smallest_display_idx" ]; then
            log_info "    space '$label' already on display $smallest_display_idx, skipping"
        else
            log_info "    moving space '$label' to display $smallest_display_idx"
            if yabai -m space "$label" --display "$smallest_display_idx"; then
                log_info "    successfully moved space '$label' to display $smallest_display_idx"
            else
                log_error "    failed to move space '$label' to display $smallest_display_idx"
            fi
        fi
        label_idx=$((label_idx + 1))
    done

    # validate final state
    log_info "validating final space distribution..."
    local validation_failed=0
    for i in "${!YABAI_SPACE_LABELS[@]}"; do
        local label="${YABAI_SPACE_LABELS[$i]}"
        local space_info
        space_info="$(yabai -m query --spaces --space "$label" 2>/dev/null || echo '{}')"
        local display
        display="$(echo "$space_info" | jq -r '.display // "unknown"')"
        log_info "  space '$label' is on display $display"
    done
}

setup_spaces() {
    destroy_excess_spaces
    create_missing_spaces
    label_spaces
    distribute_spaces_between_displays
}

log_info "running setup-spaces"
setup_spaces
log_info "done"
