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
    for _ in $(yabai -m query --spaces |
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
        local index=$((i + 1))
        local label="${YABAI_SPACE_LABELS[$i]}"
        log_info "labeling space $index as $label"
        yabai -m space "$index" --label "$label"
    done
}

move_space_to_display() {
    local label="$1"
    local target_display="$2"

    local current_display
    current_display="$(yabai -m query --spaces --space "$label" | jq -r '.display')"

    log_info "  space '$label': currently on display $current_display, target display $target_display"

    # only move the space if it's not already on the target display
    if [ "$current_display" -eq "$target_display" ]; then
        log_info "    space '$label' already on display $target_display, skipping"
    else
        log_info "    moving space '$label' to display $target_display"
        if yabai -m space "$label" --display "$target_display"; then
            log_info "    successfully moved space '$label' to display $target_display"
        else
            log_error "    failed to move space '$label' to display $target_display"
        fi
    fi
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

    local spaces_per_display=$((NUM_SPACES / num_displays))
    local smallest_display_idx
    smallest_display_idx="$(echo "$displays" | jq '.[-1].index')"

    log_info "distributing $NUM_SPACES spaces so each display has ~$spaces_per_display spaces"

    # build an assignments array: map each space index to its target display
    # first (spaces_per_display * num_displays) spaces are spread evenly;
    # any remainder goes to the smallest display
    local -a assignments=()
    for display_idx in $(echo "$displays" | jq '.[].index'); do
        for ((j = 0; j < spaces_per_display; j++)); do
            assignments+=("$display_idx")
        done
    done
    while [ "${#assignments[@]}" -lt "$NUM_SPACES" ]; do
        assignments+=("$smallest_display_idx")
    done

    # move each space to its assigned display
    for i in "${!assignments[@]}"; do
        move_space_to_display "${YABAI_SPACE_LABELS[$i]}" "${assignments[$i]}"
    done

    # validate final state
    log_info "validating final space distribution..."
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
