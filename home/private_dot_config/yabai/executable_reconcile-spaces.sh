#!/usr/bin/env bash
set -euo pipefail

sleep 5

script_dir="$(dirname "$0")"
"$script_dir/setup-spaces.sh"
"$script_dir/register-rules.sh"
"$script_dir/apply-app-spaces.sh"
