#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=SCRIPTDIR/spaces
source "$(dirname "$0")/spaces"
# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$(dirname "$0")/lib/logging.sh"

NUM_SPACES=${#YABAI_SPACE_LABELS[@]}
SPACE_LABELS_JSON="$(printf '%s\n' "${YABAI_SPACE_LABELS[@]}" | jq -R . | jq -s .)"

destroy_excess_spaces() {
	log_info "destroying excess spaces until there are $NUM_SPACES"

	for index in $(yabai -m query --spaces |
		jq -r --argjson labels "$SPACE_LABELS_JSON" '
			sort_by(.index)
			| reduce .[] as $space ({seen: [], excess: []};
				if ($labels | index($space.label)) == null
					or (.seen | index($space.label)) != null
				then .excess += [$space.index]
				else .seen += [$space.label]
				end)
			| .excess
			| reverse[]
		'); do
		log_info "destroying unmanaged space $index"
		yabai -m space --destroy "$index"
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
	log_info "labeling missing spaces"

	local label
	for label in "${YABAI_SPACE_LABELS[@]}"; do
		local spaces
		spaces="$(yabai -m query --spaces)"
		if echo "$spaces" | jq -e --arg label "$label" 'any(.[]; .label == $label)' >/dev/null; then
			log_info "preserving space labeled $label"
			continue
		fi

		local index
		index="$(echo "$spaces" | jq -r --argjson labels "$SPACE_LABELS_JSON" '
			. as $spaces
			| map(select(
				.label == ""
				or (.label as $label | $labels | index($label) == null)
				or (.label as $label | [$spaces[] | select(.label == $label)] | length > 1)
			))
			| sort_by(.index)
			| first
			| .index // empty
		')"
		if [ -z "$index" ]; then
			log_error "no unmanaged space available for missing label $label"
			return 1
		fi

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

	local displays
	displays="$(yabai -m query --displays)"

	local num_displays
	num_displays="$(echo "$displays" | jq 'length')"

	log_info "found $num_displays displays:"
	echo "$displays" | jq -r '.[] | "  display \(.index): \(.frame.w)x\(.frame.h)"'

	if [ "$num_displays" -eq 0 ]; then
		log_error "no displays found"
		return 1
	fi

	local first_display_idx
	first_display_idx="$(echo "$displays" | jq -r 'map(.index) | sort | .[0]')"
	local second_display_idx
	if [ "$num_displays" -eq 1 ]; then
		second_display_idx="$first_display_idx"
	else
		second_display_idx="$(echo "$displays" | jq -r 'map(.index) | sort | .[1]')"
	fi

	log_info "assigning spaces 1-5 to display $first_display_idx"
	log_info "assigning spaces 6-9 to display $second_display_idx"

	# move each space to its assigned display
	for i in "${!YABAI_SPACE_LABELS[@]}"; do
		local target_display="$first_display_idx"
		if [ "$i" -ge 5 ]; then
			target_display="$second_display_idx"
		fi
		move_space_to_display "${YABAI_SPACE_LABELS[$i]}" "$target_display"
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

reorder_spaces() {
	log_info "reordering spaces to match intended label order"
	for i in "${!YABAI_SPACE_LABELS[@]}"; do
		local target_index=$((i + 1))
		local label="${YABAI_SPACE_LABELS[$i]}"
		local current_index
		current_index="$(yabai -m query --spaces --space "$label" | jq '.index')"

		if [ "$current_index" -eq "$target_index" ]; then
			log_info "  space '$label' already at index $target_index"
		else
			log_info "  moving space '$label' from index $current_index to $target_index"
			yabai -m space "$label" --move "$target_index"
		fi
	done
}

setup_spaces() {
	create_missing_spaces
	label_spaces
	distribute_spaces_between_displays
	reorder_spaces
	destroy_excess_spaces
}

log_info "running setup-spaces"
setup_spaces
log_info "done"
