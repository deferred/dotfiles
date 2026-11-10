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

# create a worktree, keep its tmux session, and start opencode in window 3
ocw() {
  if [[ -z $1 ]]; then
    print -u2 'usage: ocw <branch>'
    return 1
  fi

  wt switch --no-cd --create "$@" -x sh -- -c '
    session="$(basename "$(dirname "$1")")/$2"
    tmux has-session -t "$session" 2>/dev/null ||
      tmux new-session -d -s "$session" -c "$3" ||
      tmux has-session -t "$session" || exit

    # the session hook creates window 3 for a shell, so add it only when missing
    tmux list-panes -t "$session:3" >/dev/null 2>&1 ||
      tmux new-window -d -t "$session:3" -c "$3"

    # type into a shell only, to avoid launching opencode over a running program
    case "$(tmux display-message -p -t "$session:3" "#{pane_current_command}" 2>/dev/null)" in
      zsh|bash|sh) tmux send-keys -t "$session:3" opencode Enter ;;
    esac

    tmux select-window -t "$session:3" 2>/dev/null || true

    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session" 2>/dev/null || true
    else
      tmux attach -t "$session"
    fi
  ' sh '{{ repo_path }}' '{{ branch | sanitize }}' '{{ worktree_path }}'
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
