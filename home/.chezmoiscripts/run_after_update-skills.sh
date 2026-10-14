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

lock_file="$HOME/.agents/.skill-lock.json"

while IFS= read -r skill && IFS= read -r source_url; do
	if [ ! -d "$HOME/.agents/skills/$skill" ]; then
		npx --yes skills add "$source_url" --skill "$skill" -g -y </dev/null
	fi
done < <(
	jq -r '
		.skills
		| to_entries[]
		| select(.value.sourceUrl | type == "string")
		| .key, .value.sourceUrl
	' "$lock_file"
)

npx --yes skills update -g -y </dev/null
