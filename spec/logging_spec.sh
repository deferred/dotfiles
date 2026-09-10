#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'lib/logging.sh'
Include home/private_dot_config/yabai/lib/logging.sh

Describe 'log_info'
It 'writes to stdout'
When call log_info 'hello'
The stdout should include 'hello'
The stderr should equal ''
End

It 'tags the timestamp, the calling script and the level'
When call log_info 'hello'
The stdout should match pattern '[[]*] [[]*] [[]INFO] hello'
End

It 'timestamps each line'
When call log_info 'hello'
The stdout should match pattern '[[]????-??-?? ??:??:??]*'
End
End

Describe 'log_warn'
# Warnings used to go to stdout, where they corrupted the JSON that
# yabai_json returns through command substitution.
It 'writes to stderr, never stdout'
When call log_warn 'careful'
The stderr should include 'careful'
The stderr should include '[WARN]'
The stdout should equal ''
End
End

Describe 'log_error'
It 'writes to stderr'
When call log_error 'broken'
The stderr should include 'broken'
The stderr should include '[ERROR]'
The stdout should equal ''
End
End

Describe 'enable_error_trap'
# A failed `yabai -m query` under `set -e` used to abort a script with no
# output at all, which is why the real bug went unnoticed for weeks.
run_failing_script() {
	bash -c '
			set -euo pipefail
			source "$1/lib/logging.sh"
			enable_error_trap
			log_info started
			false
			log_info unreachable
		' _ "$YABAI_SRC"
}

It 'reports the command that aborted the script'
When run run_failing_script
The status should equal 1
The stdout should include 'started'
The stdout should not include 'unreachable'
The stderr should include '[ERROR]'
The stderr should include 'aborted at line'
The stderr should include 'false'
The stderr should include 'exit 1'
End

run_passing_script() {
	bash -c '
			set -euo pipefail
			source "$1/lib/logging.sh"
			enable_error_trap
			true
			log_info finished
		' _ "$YABAI_SRC"
}

It 'stays quiet when nothing fails'
When run run_passing_script
The status should equal 0
The stdout should include 'finished'
The stderr should equal ''
End
End
End
