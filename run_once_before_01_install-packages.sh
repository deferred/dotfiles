#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

exists() {
    command -v "$1" >/dev/null 2>&1
}

# ohmyzsh
# https://github.com/ohmyzsh/ohmyzsh#unattended-install
if ! [ -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
