#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! exists brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle --file=/dev/stdin <<EOF
brew "bat"
brew "btop"
brew "chezmoi"
brew "curl"
brew "direnv"
brew "duf"
brew "eza"
brew "fd"
brew "fzf"
brew "git"
brew "htop"
brew "httpie"
brew "inetutils"
brew "iperf3"
brew "gh"
brew "jq"
brew "jrnl"
brew "lazygit"
brew "ncdu"
brew "neovim"
brew "nnn"
brew "rclone"
brew "ripgrep"
brew "rsync"
brew "thefuck"
brew "tldr"
brew "tmux"
brew "wget"
brew "yq"
brew "zoxide"
brew "zsh"
EOF

# https://github.com/ohmyzsh/ohmyzsh#unattended-install
if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
