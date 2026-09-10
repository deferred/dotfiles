#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'setup-spaces.sh'
Include home/private_dot_config/yabai/executable_setup-spaces.sh

# Layout fixtures. SPACES_JSON and DISPLAYS_JSON stand in for the live
# window server; COMMANDS records every mutating call the script makes.
setup() {
	COMMANDS_FILE="$(mktemp)"
	DISPLAYS_JSON='[{"index":1,"frame":{"w":2560,"h":1440}},{"index":2,"frame":{"w":1470,"h":956}}]'
	SPACES_JSON='[
			{"index":1,"label":"web","display":1},
			{"index":2,"label":"code","display":1},
			{"index":3,"label":"productivity","display":1},
			{"index":4,"label":"misc1","display":1},
			{"index":5,"label":"misc2","display":1},
			{"index":6,"label":"messaging","display":2},
			{"index":7,"label":"mail","display":2},
			{"index":8,"label":"music","display":2},
			{"index":9,"label":"misc3","display":2}
		]'
}
cleanup() { rm -f "$COMMANDS_FILE"; }
BeforeEach 'setup'
AfterEach 'cleanup'

commands() { cat "$COMMANDS_FILE"; }

# A fake yabai that answers queries from the fixtures and logs mutations.
yabai() {
	if [ "${2:-}" = "query" ]; then
		case "$3" in
		--spaces) echo "$SPACES_JSON" ;;
		--displays) echo "$DISPLAYS_JSON" ;;
		esac
		return 0
	fi

	# the script sets IFS=$'\n\t', so join the arguments explicitly
	(
		IFS=' '
		echo "$*"
	) >>"$COMMANDS_FILE"
	return "${YABAI_MUTATION_STATUS:-0}"
}

Describe 'create_missing_spaces'
Context 'when spaces are missing'
too_few_spaces() {
	SPACES_JSON='[{"index":1,"label":"web","display":1}]'
	YABAI_SPACE_LABELS=(web code)
}
Before 'too_few_spaces'

# One create per missing space, counted locally. Re-querying yabai here used
# to risk an endless loop whenever a create silently failed.
It 'creates spaces until the count matches'
When call create_missing_spaces
The status should be success
The output should include 'creating space 2 of 2'
The result of function commands should equal '-m space --create'
End
End

Context 'when the layout is already full'
It 'creates nothing'
When call create_missing_spaces
The status should be success
The result of function commands should equal ''
End
End
End

Describe 'label_spaces'
Context 'when every label is already assigned'
# Silence is the report: only changes are logged, and log_layout prints the
# result at the end of the run.
It 'preserves them all'
When call label_spaces
The status should be success
The output should equal ''
The result of function commands should equal ''
End
End

Context 'when a space is unlabelled'
drop_label() {
	SPACES_JSON="${SPACES_JSON//\"label\":\"messaging\"/\"label\":\"\"}"
}
Before 'drop_label'

It 'labels the free space'
When call label_spaces
The status should be success
The output should include 'labeling space 6 as messaging'
The result of function commands should include '-m space 6 --label messaging'
End
End

Context 'when macOS restored two spaces with the same label'
# The duplicate is free by definition, so the missing label takes it over
# directly. No separate step has to clear the duplicate label first.
duplicate_messaging() {
	SPACES_JSON='[
				{"index":1,"label":"messaging","display":1},
				{"index":2,"label":"messaging","display":1}
			]'
	YABAI_SPACE_LABELS=(messaging mail)
}
Before 'duplicate_messaging'

It 'relabels the duplicate copy'
When call label_spaces
The status should be success
The output should include 'labeling space 2 as mail'
The result of function commands should equal '-m space 2 --label mail'
End
End

Context 'when no space is free for a missing label'
crowd_spaces() {
	SPACES_JSON='[{"index":1,"label":"web","display":1}]'
	YABAI_SPACE_LABELS=(web messaging)
}
Before 'crowd_spaces'

It 'reports the missing label'
When call label_spaces
The status should be failure
The stderr should include 'no unmanaged space available for missing label messaging'
End
End
End

Describe 'distribute_spaces'
Context 'with two displays'
It 'splits the labels across both displays'
When call distribute_spaces
The status should be success
The output should include 'spreading the first 5 labels over display 1, the rest over display 2'
End

It 'leaves spaces that already sit on the right display'
When call distribute_spaces
The status should be success
The result of function commands should equal ''
End

Context 'and messaging stranded on the wrong display'
# The user-visible symptom: Slack and Telegram on the big screen.
strand_messaging() {
	SPACES_JSON="${SPACES_JSON//\"label\":\"messaging\",\"display\":2/\"label\":\"messaging\",\"display\":1}"
}
Before 'strand_messaging'

It 'moves messaging back to the second display'
When call distribute_spaces
The status should be success
The output should include "moving space 'messaging' from display 1 to 2"
The result of function commands should include '-m space messaging --display 2'
End
End

Context 'and a label duplicated across both displays'
duplicate_label() {
	SPACES_JSON="${SPACES_JSON%]}"',{"index":10,"label":"messaging","display":1}]'
}
Before 'duplicate_label'

It 'uses the lowest-index copy and keeps going'
When call distribute_spaces
The status should be success
The stdout should be present
The result of function commands should equal ''
End
End
End

Context 'with a single display'
single_display() {
	DISPLAYS_JSON='[{"index":1,"frame":{"w":1470,"h":956}}]'
	SPACES_JSON="${SPACES_JSON//\"display\":2/\"display\":1}"
}
Before 'single_display'

It 'collapses every label onto that display'
When call distribute_spaces
The status should be success
The output should include 'spreading the first 5 labels over display 1, the rest over display 1'
The result of function commands should equal ''
End
End

Context 'with no displays'
no_displays() { DISPLAYS_JSON='[]'; }
Before 'no_displays'

It 'reports failure'
When call distribute_spaces
The status should be failure
The stderr should include 'no displays found'
End
End
End

Describe 'reorder_spaces'
Context 'when every label already sits at its target index'
It 'moves nothing'
When call reorder_spaces
The status should be success
The output should equal ''
The result of function commands should equal ''
End
End

Context 'when a space is out of order on the same display'
setup_shifted() {
	SPACES_JSON='[
				{"index":1,"label":"code","display":1},
				{"index":2,"label":"web","display":1}
			]'
	YABAI_SPACE_LABELS=(web code)
}
Before 'setup_shifted'

It 'moves the space to its target index'
When call reorder_spaces
The status should be success
The output should include "moving space 'web' from index 2 to 1"
The result of function commands should include '-m space web --move 1'
End
End

Context 'when the target index belongs to another display'
# yabai answers "cannot move space across display boundaries" here. Under
# `set -e` that error used to abort the whole reconciliation before any
# window rule was re-applied, stranding Slack and Telegram.
setup_split() {
	SPACES_JSON='[
				{"index":1,"label":"messaging","display":1},
				{"index":2,"label":"web","display":2}
			]'
	YABAI_SPACE_LABELS=(web messaging)
}
Before 'setup_split'

It 'skips the move instead of attempting it'
When call reorder_spaces
The status should be success
The stderr should include "skipping 'web'"
The stderr should include 'index 1 is on display 1'
The stderr should include 'space is on display 2'
The result of function commands should equal ''
End
End

Context 'when a label has no space at all'
setup_missing() {
	SPACES_JSON='[{"index":1,"label":"web","display":1}]'
	YABAI_SPACE_LABELS=(web messaging)
}
Before 'setup_missing'

It 'warns and keeps going'
When call reorder_spaces
The status should be success
The stderr should include "space 'messaging' not found"
The result of function commands should equal ''
End
End

Context 'when yabai rejects the move anyway'
setup_failing() {
	SPACES_JSON='[
				{"index":1,"label":"code","display":1},
				{"index":2,"label":"web","display":1}
			]'
	YABAI_SPACE_LABELS=(web code)
	YABAI_MUTATION_STATUS=1
}
Before 'setup_failing'

It 'logs the failure and still returns success'
When call reorder_spaces
The status should be success
The stdout should be present
The stderr should include '[WARN]'
The stderr should include 'failed'
End
End
End

Describe 'destroy_excess_spaces'
Context 'when the layout is exactly right'
It 'destroys nothing'
When call destroy_excess_spaces
The status should be success
The result of function commands should equal ''
End
End

Context 'when macOS added a space during the display change'
add_stray_space() {
	SPACES_JSON="${SPACES_JSON%]}"',{"index":10,"label":"","display":2}]'
}
Before 'add_stray_space'

It 'destroys the unmanaged space'
When call destroy_excess_spaces
The status should be success
The output should include 'destroying unmanaged space 10'
The result of function commands should include '-m space --destroy 10'
End
End

Context 'when a label is duplicated'
duplicate_label() {
	SPACES_JSON="${SPACES_JSON%]}"',{"index":10,"label":"messaging","display":2}]'
}
Before 'duplicate_label'

It 'destroys the later copy only'
When call destroy_excess_spaces
The status should be success
The result of function commands should include '-m space --destroy 10'
The result of function commands should not include '--destroy 6'
End
End

Context 'when several spaces are excess'
two_stray_spaces() {
	SPACES_JSON="${SPACES_JSON%]}"',{"index":10,"label":"","display":2},{"index":11,"label":"","display":2}]'
}
Before 'two_stray_spaces'

# Destroying the lowest index first would renumber the others, so the
# highest index has to go first.
It 'destroys them from the highest index down'
When call destroy_excess_spaces
The status should be success
The result of function commands should equal '-m space --destroy 11
-m space --destroy 10'
End
End
End

Describe 'log_layout'
It 'prints every space in index order'
When call log_layout
The status should be success
The output should include 'index 1: web on display 1'
The output should include 'index 6: messaging on display 2'
End

Context 'when the query never parses'
# Logging the layout is cosmetic. Under `set -e` a failure here used to
# fail the whole script, so reconcile-spaces.sh reported a bogus
# "setup-spaces.sh failed" after a run that actually worked.
break_query() {
	yabai() {
		printf 'not json'
		return 1
	}
	YABAI_RETRIES=1
}
Before 'break_query'

It 'never fails the run'
When call log_layout
The status should be success
The stdout should be present
The stderr should include '[ERROR]'
End
End
End

Describe 'setup_spaces'
Context 'when the layout already matches'
It 'changes nothing and runs a single pass'
When call setup_spaces
The status should be success
The output should include 'final layout:'
The output should not include 'repeating'
The result of function commands should equal ''
End
End

Context 'when the layout keeps looking wrong'
# The fixture never changes, so every pass finds the same work to do. The
# cap is what stops a storm of display events from looping forever.
never_settles() {
	SPACES_JSON='[
				{"index":1,"label":"code","display":1},
				{"index":2,"label":"web","display":1}
			]'
	YABAI_SPACE_LABELS=(web code)
}
Before 'never_settles'

It 'stops after three passes'
When call setup_spaces
The status should be success
The stdout should include 'pass 1 changed'
The stdout should include 'pass 2 changed'
The stdout should not include 'pass 3 changed'
The stderr should include 'layout still changing after 3 passes, giving up'
End
End

Context 'when a step fails'
# A failure must not hide the rest of the work, and it must be reported so
# reconcile-spaces.sh can log it.
no_room_to_label() {
	SPACES_JSON='[{"index":1,"label":"web","display":1}]'
	YABAI_SPACE_LABELS=(web messaging)
}
Before 'no_room_to_label'

It 'reports failure but still logs the layout'
When call setup_spaces
The status should be failure
The stdout should include 'final layout:'
The stderr should include 'no unmanaged space available'
End
End
End
End
