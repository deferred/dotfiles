if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

# switch to a worktree and the corresponding tmux session.
#
# use wt's target values because the invoking directory may be a bare repo
# and post-switch hooks may still be creating the tmux session
#
# keep client switching here so wtc/wtcb do not move the current terminal
wts() {
  if [[ -z $TMUX ]]; then
    wt switch --no-cd "$@"
    return
  fi

  wt switch --no-cd "$@" -x sh -- -c '
    session="$(basename "$(dirname "$1")")/$2"
    tmux has-session -t "$session" 2>/dev/null ||
      tmux new-session -d -s "$session" -c "$3" ||
      tmux has-session -t "$session" || exit
    tmux switch-client -t "$session"
  ' sh '{{ repo_path }}' '{{ branch | sanitize }}' '{{ worktree_path }}'
}

wtsd() {
  wts ^
}

alias wtc='wt switch --no-cd --create'
alias wtcb='wt switch --no-cd --no-verify --create'
alias wtr='wt remove'

wtp() {
  local candidates
  candidates=$(wt step prune --min-age=0s --dry-run --format=json) || return
  [[ $candidates == "[]" ]] && return 0

  wt step prune --min-age=0s --dry-run || return

  read -q "reply?Delete these merged worktrees and branches? [y/N] " || {
    printf '\n'
    return 0
  }

  printf '\n'
  wt step prune --min-age=0s
}
