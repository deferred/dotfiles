#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=SCRIPTDIR/spaces
source "$script_dir/spaces"
# shellcheck source=SCRIPTDIR/lib/logging.sh
source "$script_dir/lib/logging.sh"
# shellcheck source=SCRIPTDIR/lib/yabai.sh
source "$script_dir/lib/yabai.sh"

NUM_SPACES=${#YABAI_SPACE_LABELS[@]}
SPACE_LABELS_JSON="$(printf '%s\n' "${YABAI_SPACE_LABELS[@]}" | jq -R . | jq -s .)"

destroy_excess_spaces() {
	log_info "destroying excess spaces until there are $NUM_SPACES"

	local spaces
	spaces="$(yabai_json -m query --spaces)" || return 1

	local index
	for index in $(echo "$spaces" |
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
		yabai_try -m space --destroy "$index" || true
	done
}

create_missing_spaces() {
	log_info "creating missing spaces until there are $NUM_SPACES"

	local count
	while :; do
		count="$(yabai_json -m query --spaces | jq length)" || return 1
		[ "$count" -lt "$NUM_SPACES" ] || break

		log_info "creating space"
		yabai_try -m space --create || return 1
	done
}

label_spaces() {
	log_info "labeling missing spaces"

	local label spaces index
	for label in "${YABAI_SPACE_LABELS[@]}"; do
		spaces="$(yabai_json -m query --spaces)" || return 1
		if echo "$spaces" | jq -e --arg label "$label" 'any(.[]; .label == $label)' >/dev/null; then
			log_info "preserving space labeled $label"
			continue
		fi

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
		yabai_try -m space "$index" --label "$label" || return 1
	done
}

distribute_spaces_between_displays() {
	log_info "distributing spaces between displays"

	local displays
	displays="$(yabai_json -m query --displays)" || return 1

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

	local i label target_display spaces current_display
	for i in "${!YABAI_SPACE_LABELS[@]}"; do
		label="${YABAI_SPACE_LABELS[$i]}"

		target_display="$first_display_idx"
		if [ "$i" -ge 5 ]; then
			target_display="$second_display_idx"
		fi

		spaces="$(yabai_json -m query --spaces)" || return 1
		# Take the first match. destroy_excess_spaces removes duplicate labels,
		# but it runs last, so two spaces can still share a label here.
		current_display="$(echo "$spaces" |
			jq -r --arg label "$label" 'first(.[] | select(.label == $label) | .display) // empty')"

		if [ -z "$current_display" ]; then
			log_warn "  space '$label' not found, skipping"
			continue
		fi

		if [ "$current_display" -eq "$target_display" ]; then
			log_info "  space '$label' already on display $target_display"
			continue
		fi

		log_info "  moving space '$label' from display $current_display to $target_display"
		yabai_try -m space "$label" --display "$target_display" || true
	done
}

reorder_spaces() {
	log_info "reordering spaces to match intended label order"

	local i label target_index spaces current_index current_display target_display
	for i in "${!YABAI_SPACE_LABELS[@]}"; do
		target_index=$((i + 1))
		label="${YABAI_SPACE_LABELS[$i]}"

		spaces="$(yabai_json -m query --spaces)" || return 1
		# Take the first match; a label can still be duplicated at this point.
		current_index="$(echo "$spaces" |
			jq -r --arg label "$label" 'first(.[] | select(.label == $label) | .index) // empty')"

		if [ -z "$current_index" ]; then
			log_warn "  space '$label' not found, skipping"
			continue
		fi

		if [ "$current_index" -eq "$target_index" ]; then
			log_info "  space '$label' already at index $target_index"
			continue
		fi

		# yabai refuses to move a space across displays, and that failure used
		# to abort the whole reconciliation before any rule was re-applied.
		current_display="$(echo "$spaces" |
			jq -r --argjson index "$current_index" 'first(.[] | select(.index == $index) | .display) // empty')"
		target_display="$(echo "$spaces" |
			jq -r --argjson index "$target_index" 'first(.[] | select(.index == $index) | .display) // empty')"

		if [ -n "$target_display" ] && [ "$current_display" != "$target_display" ]; then
			log_warn "  skipping '$label': index $target_index is on display $target_display, space is on display $current_display"
			continue
		fi

		log_info "  moving space '$label' from index $current_index to $target_index"
		yabai_try -m space "$label" --move "$target_index" || true
	done
}

# Purely cosmetic, so it must never fail the run. A failure here used to make
# reconcile-spaces.sh report a bogus "setup-spaces.sh failed".
log_layout() {
	log_info "final layout:"
	yabai_json -m query --spaces |
		jq -r 'sort_by(.index)[] | "  index \(.index): \(.label) on display \(.display)"' ||
		true
}

setup_spaces() {
	create_missing_spaces
	label_spaces
	distribute_spaces_between_displays
	reorder_spaces
	destroy_excess_spaces
	log_layout
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

enable_error_trap

log_info "running setup-spaces"
setup_spaces
log_info "done"
