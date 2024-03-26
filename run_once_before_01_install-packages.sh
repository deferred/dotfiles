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

# rust
# https://www.rust-lang.org/tools/install
# https://github.com/rust-lang/rustup/issues/297#issuecomment-444818896
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"

# node
# https://github.com/nvm-sh/nvm#usage
. ~/.nvm/nvm.sh
nvm install node

# lunarvim
if ! exists lvim; then
  ( cd $(python -c 'import site; print(site.getsitepackages()[-1])')/.. \
    && [ ! -f EXTERNALLY-MANAGED ] || sudo mv EXTERNALLY-MANAGED EXTERNALLY-MANAGED.tmp \
    && LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) -y \
    && sudo mv EXTERNALLY-MANAGED.tmp EXTERNALLY-MANAGED
  )
fi
