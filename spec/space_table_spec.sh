#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'lib/space-table.sh'
Include home/private_dot_config/yabai/lib/logging.sh
Include home/private_dot_config/yabai/lib/yabai.sh
Include home/private_dot_config/yabai/lib/space-table.sh

setup() {
	YABAI_SPACE_LABELS=(web code messaging)
	SPACES_JSON='[
			{"index":1,"label":"web","display":1},
			{"index":2,"label":"","display":1},
			{"index":3,"label":"messaging","display":2},
			{"index":4,"label":"leftover","display":2}
		]'
}
BeforeEach 'setup'

yabai() { echo "$SPACES_JSON"; }

Describe 'read_spaces'
It 'fills the table from the live layout'
When call read_spaces
The status should be success
The variable TABLE should equal "1${TAB}1${TAB}web
2${TAB}1${TAB}
3${TAB}2${TAB}messaging
4${TAB}2${TAB}leftover"
End

Context 'when the query never parses'
break_query() {
	yabai() {
		printf 'not json'
		return 1
	}
	YABAI_RETRIES=1
}
Before 'break_query'

It 'reports failure and leaves the table empty'
When call read_spaces
The status should be failure
The variable TABLE should equal ''
The stderr should be present
End
End
End

Describe 'the lookups'
Before 'read_spaces'

It 'finds the index of a label'
When call index_of messaging
The output should equal '3'
End

It 'returns nothing for a label with no space'
When call index_of mail
The output should equal ''
End

It 'finds the display of a label'
When call display_of_label messaging
The output should equal '2'
End

It 'finds the display of an index'
When call display_of_index 4
The output should equal '2'
End

It 'counts the spaces'
When call space_count
The output should equal '4'
End

It 'lists the table highest index first'
When call reverse_table
The line 1 of output should equal "4${TAB}2${TAB}leftover"
The line 4 of output should equal "1${TAB}1${TAB}web"
End
End

Describe 'keeper_indexes'
Before 'read_spaces'

It 'lists one index per label that exists'
When call keeper_indexes
The status should be success
The output should equal '1
3'
End

Context 'when a label is duplicated'
duplicate_web() {
	SPACES_JSON='[
				{"index":1,"label":"web","display":1},
				{"index":2,"label":"web","display":1}
			]'
	read_spaces
}
Before 'duplicate_web'

# The lowest index wins, so the later copy is free to be reused or destroyed.
It 'keeps only the lowest index'
When call keeper_indexes
The output should equal '1'
End
End
End

Describe 'first_free_space'
Before 'read_spaces'

# The unlabelled space at index 2 comes before the stray label at index 4.
It 'returns the lowest index that keeps no wanted label'
When call first_free_space
The output should equal '2'
End

Context 'when a label is duplicated'
duplicate_web() {
	SPACES_JSON='[
				{"index":1,"label":"web","display":1},
				{"index":2,"label":"web","display":1}
			]'
	read_spaces
}
Before 'duplicate_web'

# The second copy is free, so a missing label can take it over directly,
# with no separate step to clear the duplicate first.
It 'offers the duplicate copy'
When call first_free_space
The output should equal '2'
End
End

Context 'when every space keeps a wanted label'
all_taken() {
	SPACES_JSON='[
				{"index":1,"label":"web","display":1},
				{"index":2,"label":"code","display":1}
			]'
	read_spaces
}
Before 'all_taken'

It 'returns nothing'
When call first_free_space
The output should equal ''
End
End
End
End
