eval "$(/opt/homebrew/bin/brew shellenv)"

brew() {
  if [[ "$1" == "services" ]]; then
    command brew "$@"
  else
    (cd /opt/homebrew && sudo -Hu homebrew brew "$@")
  fi
}
