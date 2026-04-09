if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

# resolve wt branch shortcuts (^, -, @) to actual branch names
_wt_resolve_branch() {
  case $1 in
    ^)  wt config state default-branch ;;
    -)  wt config state previous-branch ;;
    @)  git rev-parse --abbrev-ref HEAD 2>/dev/null ;;
    *)  echo "$1" ;;
  esac
}

# switch to a worktree and the corresponding tmux session.
#
# wt's post-switch hook creates tmux sessions but intentionally does not call
# tmux switch-client — that would also fire on wtc/wtcb, switching the user's
# terminal away from the current session. instead, wts handles the tmux switch
# here so only interactive switches move the client.
#
# branch shortcuts (^, -, @) are resolved before calling wt because we need the
# actual branch name to build the tmux session identifier (repo/branch).
wts() {
  local branch
  branch=$(_wt_resolve_branch "$1")
  wt switch --no-cd "$@" || return
  [[ -n $TMUX ]] || return 0
  local repo session
  repo=$(basename "$(dirname "$(git rev-parse --show-toplevel 2>/dev/null)")")
  session="${repo}/${branch//[\/\\]/-}"
  tmux has-session -t "$session" 2>/dev/null &&
    tmux switch-client -t "$session"
}

wtsd() {
  wts ^
}

alias wtc='wt switch --no-cd --create'
alias wtcb='wt switch --no-cd --no-verify --create'
alias wtr='wt remove'
