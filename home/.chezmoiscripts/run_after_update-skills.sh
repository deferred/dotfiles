#!/usr/bin/env bash

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
	for brew_path in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
		if [ -x "$brew_path" ]; then
			eval "$("$brew_path" shellenv)"
			break
		fi
	done
fi

npx --yes skills update -g -y
