#!/usr/bin/env bash
# shellcheck shell=bash

# One-line bootstrap for every yabai script:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/bootstrap.sh"

set -euo pipefail
IFS=$'\n\t'

yabai_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=SCRIPTDIR/logging.sh
source "$yabai_dir/lib/logging.sh"
# shellcheck source=SCRIPTDIR/yabai.sh
source "$yabai_dir/lib/yabai.sh"
# shellcheck source=SCRIPTDIR/../spaces
source "$yabai_dir/spaces"
# shellcheck source=SCRIPTDIR/space-table.sh
source "$yabai_dir/lib/space-table.sh"

# The spec suite sets __SOURCED__ to load a script without running its body.
# Leave the ERR trap off in that case, because shellspec exercises failing
# paths on purpose.
${__SOURCED__:+return}

enable_error_trap
