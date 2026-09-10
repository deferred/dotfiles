#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'lib/yabai.sh'
Include home/private_dot_config/yabai/lib/logging.sh
Include home/private_dot_config/yabai/lib/yabai.sh

# Counts calls so a fake can fail a fixed number of times before succeeding,
# the way yabai does while macOS is still moving spaces around.
setup() {
	CALLS_FILE="$(mktemp)"
	echo 0 >"$CALLS_FILE"
}
cleanup() { rm -f "$CALLS_FILE"; }
BeforeEach 'setup'
AfterEach 'cleanup'

calls() { cat "$CALLS_FILE"; }
record_call() {
	local count
	count="$(cat "$CALLS_FILE")"
	echo $((count + 1)) >"$CALLS_FILE"
	echo "$count"
}

Describe 'yabai_json'
Context 'when yabai answers immediately'
yabai() {
	record_call >/dev/null
	echo '[{"index":1,"label":"web"}]'
}

It 'returns the payload without retrying'
When call yabai_json -m query --spaces
The status should be success
The output should equal '[{"index":1,"label":"web"}]'
The output should valid_json
The stderr should equal ''
The result of function calls should equal 1
End
End

Context 'when yabai truncates its JSON mid transition'
# The exact failure from the logs: a partial body plus a non-zero exit.
yabai() {
	local n
	n="$(record_call)"
	if [ "$n" -lt 2 ]; then
		printf '[{"index":1,'
		return 1
	fi
	echo '[{"index":1,"label":"web"}]'
}

It 'retries until the payload parses'
When call yabai_json -m query --spaces
The status should be success
The output should equal '[{"index":1,"label":"web"}]'
The output should valid_json
The stderr should be present
End

It 'keeps the retry warnings out of stdout'
When call yabai_json -m query --spaces
The output should valid_json
The stderr should include 'attempt 1/'
The stderr should include 'attempt 2/'
End

It 'stops retrying once the query succeeds'
When call yabai_json -m query --spaces
The output should valid_json
The stderr should be present
The result of function calls should equal 3
End
End

Context 'when yabai returns valid JSON but a non-zero status'
yabai() {
	record_call >/dev/null
	echo '[]'
	return 1
}

It 'treats the call as failed'
When call yabai_json -m query --spaces
The status should be failure
The stderr should include 'after 10 attempts'
End
End

Context 'when yabai never recovers'
yabai() {
	record_call >/dev/null
	printf 'not json'
	return 1
}

It 'gives up after the retry budget and reports failure'
YABAI_RETRIES=3
When call yabai_json -m query --spaces
The status should be failure
The stderr should include 'attempt 3/3'
The stderr should include '[ERROR]'
The stderr should include 'after 3 attempts'
The result of function calls should equal 3
End

It 'emits nothing on stdout so callers cannot parse garbage'
YABAI_RETRIES=2
When call yabai_json -m query --spaces
The status should be failure
The stdout should equal ''
The stderr should be present
End
End
End

Describe 'yabai_soft'
Context 'when the command succeeds'
yabai() { return 0; }

It 'reports success quietly'
When call yabai_soft -m space messaging --move 6
The status should be success
The stderr should equal ''
End
End

Context 'when the command fails'
# yabai refuses cross-display moves. That failure must not be fatal.
yabai() {
	echo 'cannot move space across display boundaries.' >&2
	return 1
}

# Always succeeding is the point: callers need no `|| true`, so a single
# rejected move cannot abort a script running under `set -e`.
It 'warns but still reports success'
When call yabai_soft -m space messaging --move 3
The status should be success
The stderr should include '[WARN]'
The stderr should include 'yabai -m space messaging --move 3 failed'
End

It 'does not retry a non-query command'
When call yabai_soft -m space messaging --move 3
The status should be success
The stderr should not include 'attempt'
End
End
End

Describe 'spaces_table'
Context 'when the query succeeds'
yabai() {
	echo '[
			{"index":2,"label":"code","display":1},
			{"index":1,"label":"web","display":1},
			{"index":3,"label":"","display":2}
		]'
}

# Label comes last because it can be empty, and `read` collapses the
# consecutive tabs an empty middle field would produce.
It 'prints index, display and label, sorted by index'
When call spaces_table
The status should be success
The lines of output should equal 3
The line 1 of output should equal "1${TAB}1${TAB}web"
The line 2 of output should equal "2${TAB}1${TAB}code"
The line 3 of output should equal "3${TAB}2${TAB}"
End
End

Context 'when the query never parses'
yabai() {
	printf 'not json'
	return 1
}

It 'fails instead of printing an empty table'
YABAI_RETRIES=1
When call spaces_table
The status should be failure
The stdout should equal ''
The stderr should be present
End
End
End
End
