#!/usr/bin/env bash
# shellcheck shell=bash

# Directory holding the chezmoi source of the yabai config. The files still
# carry chezmoi's `executable_` prefix here; `spaces` and `lib/` do not.
YABAI_SRC="$PWD/home/private_dot_config/yabai"
export YABAI_SRC

# Never sleep between retries while testing.
export YABAI_RETRY_DELAY=0

# Field separator of the space table, for assertions that must be exact.
TAB=$'\t'

# Sourcing a yabai script must not run its main body. Deliberately not
# exported: scripts started as subprocesses must still run normally.
__SOURCED__=1

spec_helper_precheck() {
	if [ ! -d "$YABAI_SRC" ]; then
		abort "run shellspec from the chezmoi repository root"
	fi

	minimum_version "0.28.0"
}

spec_helper_loaded() { :; }

# Copy the chezmoi source into a runnable config directory. Dropping the
# `executable_` prefix is what lets the scripts call each other by real name.
install_yabai_config() {
	local target="$1" path name
	mkdir -p "$target"
	cp -R "$YABAI_SRC/lib" "$target/lib"
	cp "$YABAI_SRC/spaces" "$target/spaces"

	for path in "$YABAI_SRC"/executable_*; do
		name="$(basename "$path")"
		name="${name#executable_}"
		cp "$path" "$target/$name"
		chmod +x "$target/$name"
	done
}

spec_helper_configure() {
	import 'support/custom_matcher'
}
