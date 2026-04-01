if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

alias wts='wt switch --no-cd'
alias wtsd='wt switch --no-cd ^'
alias wtc='wt switch --no-cd --create'
alias wtcb='wt switch --no-cd --no-verify --create'
alias wtr='wt remove'
