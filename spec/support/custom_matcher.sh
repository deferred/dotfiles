#!/usr/bin/env bash
# shellcheck shell=bash

# `The output should be valid_json` — the whole point of yabai_json is that it
# never hands truncated JSON to its caller.
shellspec_syntax 'shellspec_matcher_valid_json'

shellspec_matcher_valid_json() {
	shellspec_matcher__match() {
		[ "${SHELLSPEC_SUBJECT+x}" ] || return 1
		printf '%s' "$SHELLSPEC_SUBJECT" | jq -e . >/dev/null 2>&1
	}

	shellspec_matcher__failure_message() {
		shellspec_puts "expected valid JSON, got: $1"
	}

	shellspec_matcher__failure_message_when_negated() {
		shellspec_puts "expected invalid JSON, got: $1"
	}

	shellspec_matcher_do_match
}
