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

Describe 'yabai_try'
Context 'when the command succeeds'
yabai() { return 0; }

It 'reports success quietly'
When call yabai_try -m space messaging --move 6
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

It 'reports failure without aborting the caller'
When call yabai_try -m space messaging --move 3
The status should be failure
The stderr should include '[WARN]'
The stderr should include 'yabai -m space messaging --move 3 failed'
End

It 'does not retry a non-query command'
When call yabai_try -m space messaging --move 3
The status should be failure
The stderr should not include 'attempt'
End
End
End
End
