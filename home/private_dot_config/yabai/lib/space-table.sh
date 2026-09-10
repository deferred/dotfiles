#!/usr/bin/env bash
# shellcheck shell=bash

# Read-only lookups over one snapshot of the space layout, so the scripts can
# make decisions in plain bash instead of a jq program per question.
#
# read_spaces fills TABLE with `index<TAB>display<TAB>label` lines sorted by
# index. Label comes last because it can be empty, and `read` collapses the
# consecutive tabs an empty middle field would produce.

TABLE=""

read_spaces() {
	TABLE="$(spaces_table)" || return 1
}

index_of() { awk -F'\t' -v want="$1" '$3 == want { print $1; exit }' <<<"$TABLE"; }
display_of_label() { awk -F'\t' -v want="$1" '$3 == want { print $2; exit }' <<<"$TABLE"; }
display_of_index() { awk -F'\t' -v want="$1" '$1 == want { print $2; exit }' <<<"$TABLE"; }
space_count() { awk 'NF { n++ } END { print n + 0 }' <<<"$TABLE"; }

# Highest index first, so destroying a space cannot renumber the ones still
# waiting to be destroyed.
reverse_table() { sort -rn <<<"$TABLE"; }

# The space that keeps each wanted label: the lowest index carrying it. One
# concept covers every other space, whether it is unlabelled, carries a label
# nobody asked for, or is a duplicate macOS restored. Such a space is free to
# relabel and safe to destroy.
keeper_indexes() {
	local label index
	for label in "${YABAI_SPACE_LABELS[@]}"; do
		index="$(index_of "$label")"
		[ -z "$index" ] || printf '%s\n' "$index"
	done
}

is_keeper() { printf '%s\n' "$1" | grep -qxF "$2"; }

first_free_space() {
	local keepers index
	keepers="$(keeper_indexes)"
	while IFS=$'\t' read -r index _; do
		[ -n "$index" ] || continue
		if ! is_keeper "$keepers" "$index"; then
			printf '%s\n' "$index"
			return 0
		fi
	done <<<"$TABLE"
}
