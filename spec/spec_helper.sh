#!/usr/bin/env bash
# shellcheck shell=bash

# Directory holding the chezmoi source of the yabai config. The files still
# carry chezmoi's `executable_` prefix here; `spaces` and `lib/` do not.
YABAI_SRC="$PWD/home/private_dot_config/yabai"
export YABAI_SRC

# Never sleep between retries while testing.
export YABAI_RETRY_DELAY=0

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

spec_helper_configure() {
	import 'support/custom_matcher'
}
