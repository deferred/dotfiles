#!/usr/bin/env bash

# shellcheck source=SCRIPTDIR/lib/bootstrap.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

# The first five labels live on the lower display index, the rest on the next.
SPACES_ON_FIRST_DISPLAY=5

# Every phase reads the table once, then logs only what it changes. The final
# layout is logged at the end, so silence means the layout was already right.
CHANGES=0
changed() { CHANGES=$((CHANGES + 1)); }

# Add Mission Control spaces with `yabai -m space --create` until every
# label has a space. yabai can exit 0 without adding one, so query again
# after each call and stop if the space count did not rise.
create_missing_spaces() {
	read_spaces || return 1

	local count total before
	count="$(space_count)"
	total="${#YABAI_SPACE_LABELS[@]}"
	while [ "$count" -lt "$total" ]; do
		log_info "creating space $((count + 1)) of $total"
		before="$count"
		yabai_soft -m space --create
		read_spaces || return 1
		count="$(space_count)"
		if [ "$count" -le "$before" ]; then
			log_error "space --create did not add a space"
			return 1
		fi
		changed
	done
}

label_spaces() {
	read_spaces || return 1

	local label index
	for label in "${YABAI_SPACE_LABELS[@]}"; do
		[ -z "$(index_of "$label")" ] || continue

		index="$(first_free_space)"
		if [ -z "$index" ]; then
			log_error "no unmanaged space available for missing label $label"
			return 1
		fi

		log_info "labeling space $index as $label"
		yabai_soft -m space "$index" --label "$label"
		changed
		read_spaces || return 1
	done
}

# The lower display index first, then the next one. A single display takes both
# halves of the label list.
read_display_pair() {
	local indexes
	indexes="$(yabai_json -m query --displays | jq -r 'map(.index) | sort | .[]')" || return 1
	if [ -z "$indexes" ]; then
		log_error "no displays found"
		return 1
	fi

	FIRST_DISPLAY="$(head -1 <<<"$indexes")"
	SECOND_DISPLAY="$(sed -n '2p' <<<"$indexes")"
	SECOND_DISPLAY="${SECOND_DISPLAY:-$FIRST_DISPLAY}"
}

distribute_spaces() {
	read_display_pair || return 1
	read_spaces || return 1

	log_info "spreading the first $SPACES_ON_FIRST_DISPLAY labels over display $FIRST_DISPLAY, the rest over display $SECOND_DISPLAY"

	local i label target current
	for i in "${!YABAI_SPACE_LABELS[@]}"; do
		label="${YABAI_SPACE_LABELS[$i]}"
		target="$FIRST_DISPLAY"
		[ "$i" -lt "$SPACES_ON_FIRST_DISPLAY" ] || target="$SECOND_DISPLAY"

		current="$(display_of_label "$label")"
		if [ -z "$current" ]; then
			log_warn "space '$label' not found, skipping"
			continue
		fi
		[ "$current" != "$target" ] || continue

		log_info "moving space '$label' from display $current to $target"
		yabai_soft -m space "$label" --display "$target"
		changed
	done
}

reorder_spaces() {
	read_spaces || return 1

	local i label target current
	for i in "${!YABAI_SPACE_LABELS[@]}"; do
		target=$((i + 1))
		label="${YABAI_SPACE_LABELS[$i]}"

		current="$(index_of "$label")"
		if [ -z "$current" ]; then
			log_warn "space '$label' not found, skipping"
			continue
		fi
		[ "$current" != "$target" ] || continue
		crosses_displays "$label" "$current" "$target" && continue

		log_info "moving space '$label' from index $current to $target"
		yabai_soft -m space "$label" --move "$target"
		changed
		# a move renumbers every space after it
		read_spaces || return 1
	done
}

# yabai refuses to move a space across displays, and that failure used to abort
# the whole reconciliation before any window rule was re-applied.
crosses_displays() {
	local label="$1" from to
	from="$(display_of_index "$2")"
	to="$(display_of_index "$3")"
	if [ -z "$to" ] || [ "$from" = "$to" ]; then
		return 1
	fi

	log_warn "skipping '$label': index $3 is on display $to, space is on display $from"
}

destroy_excess_spaces() {
	read_spaces || return 1

	local keepers index
	keepers="$(keeper_indexes)"
	while IFS=$'\t' read -r index _; do
		[ -n "$index" ] || continue
		is_keeper "$keepers" "$index" && continue

		log_info "destroying unmanaged space $index"
		yabai_soft -m space --destroy "$index"
		changed
	done <<<"$(reverse_table)"
}

# Purely cosmetic, so it must never fail the run. A failure here used to make
# reconcile-spaces.sh report a bogus "setup-spaces.sh failed".
log_layout() {
	local index display label
	read_spaces || TABLE=""

	log_info "final layout:"
	while IFS=$'\t' read -r index display label; do
		[ -n "$index" ] || continue
		log_info "  index $index: $label on display $display"
	done <<<"$TABLE"
}

run_pass() {
	local step status=0
	for step in create_missing_spaces label_spaces \
		distribute_spaces reorder_spaces destroy_excess_spaces; do
		"$step" || status=1
	done
	return "$status"
}

# Repeat while the layout keeps changing. macOS shifts indexes underneath us
# during a display change, so one pass is not always enough.
setup_spaces() {
	local pass status=0 passes="${SETUP_PASSES:-3}"
	for ((pass = 1; pass <= passes; pass++)); do
		CHANGES=0
		status=0
		run_pass || status=1

		[ "$CHANGES" -gt 0 ] || break
		if [ "$pass" -lt "$passes" ]; then
			log_info "pass $pass changed $CHANGES things, repeating"
		else
			log_warn "layout still changing after $passes passes, giving up"
		fi
	done

	log_layout
	return "$status"
}

# let the spec suite source this file without running it
${__SOURCED__:+return}

log_info "running setup-spaces"
setup_spaces
log_info "done"
