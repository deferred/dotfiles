#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

exists() {
	command -v "$1" >/dev/null 2>&1
}

if ! exists brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	for brew_path in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
		if [ -x "$brew_path" ]; then
			eval "$("$brew_path" shellenv)"
			break
		fi
	done
fi

BREWFILE=$(
	cat <<'EOF'
brew "anomalyco/tap/opencode"

brew "bat"
brew "bat-extras"
brew "btop"
brew "ccmux"
brew "chezmoi"
brew "curl"
brew "direnv"
brew "duf"
brew "eza"
brew "fd"
brew "fzf"
brew "git"
brew "go"
brew "htop"
brew "httpie"
brew "inetutils"
brew "iperf3"
brew "gh"
brew "jq"
brew "lazygit"
brew "ncdu"
brew "neovim"
brew "nnn"
brew "node"
brew "python"
brew "rclone"
brew "ripgrep"
brew "rsync"
brew "sesh"
brew "thefuck"
brew "tlrc"
brew "tmux"
brew "tree-sitter"
brew "uv"
brew "wget"
brew "worktrunk"
brew "yq"
brew "zoxide"
brew "zsh"
EOF
)

# trust each third-party tap referenced by a qualified brew line
# keep older Homebrew versions working when `brew trust` is unavailable
printf '%s\n' "$BREWFILE" |
	grep -oE 'brew "[^"]+/[^"]+/' |
	sed -E 's/brew "(.+)\/$/\1/' | sort -u |
	while read -r tap; do brew trust --tap "$tap" 2>/dev/null || true; done

printf '%s\n' "$BREWFILE" | brew bundle --file=/dev/stdin

if ! exists claude; then
	curl -fsSL https://claude.ai/install.sh | bash
fi

# https://github.com/ohmyzsh/ohmyzsh#unattended-install
if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
