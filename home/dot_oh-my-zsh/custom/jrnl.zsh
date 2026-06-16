# jrnl: write an entry, then auto-commit + sync the journal repo.
# subject = jrnl(<first-tag>): <entry text, lowercased, no trailing period>.
# assumes jq is installed and the journal lives in a git repo.

jrnl() {
  local dir
  local logfile
  local subject
  _jrnl_resolve_dir
  dir=$_JRNL_DIR
  logfile=$(_jrnl_resolve_log)
  mkdir -p "${logfile%/*}"

  _jrnl_pull_remote "$dir" "$logfile"
  command jrnl "$@"

  subject=$(_jrnl_build_subject "$@")
  _jrnl_commit "$dir" "$subject" || return
  _jrnl_push_remote "$dir" "$logfile" "$subject"
}

# resolve the default journal's directory from jrnl's own config into _JRNL_DIR.
# sets a session global (no stdout) so it survives across calls — capturing via
# $(...) would run in a subshell and lose the cache. memoized to skip the extra
# jrnl spawn on every later call.
_jrnl_resolve_dir() {
  [ -n "$_JRNL_DIR" ] && return
  local journal
  journal=$(command jrnl --list --format json 2>/dev/null | jq -r '.journals.default.journal')
  journal=${journal/#\~/$HOME}
  if [ -d "$journal" ]; then
    _JRNL_DIR=$journal
  else
    _JRNL_DIR=$(dirname "$journal")
  fi
}

# resolve the sync log path (XDG state dir, not the repo)
_jrnl_resolve_log() {
  printf '%s/jrnl/sync.log' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

# ff-only pull in the background (subshell so no job-control message); logged.
# detached to keep network latency off the prompt; --ff-only fails safely if
# the local repo has diverged and self-heals on a later call.
_jrnl_pull_remote() {
  local dir=$1
  local logfile=$2
  _jrnl_has_origin "$dir" || return 0
  (
    {
      printf '[%s] pull\n' "$(date '+%F %T')"
      git -C "$dir" pull --ff-only -q
    } >>"$logfile" 2>&1 &
  )
}

# true if an origin remote is configured
_jrnl_has_origin() {
  git -C "$1" remote get-url origin >/dev/null 2>&1
}

# build conventional subject: jrnl(<first-tag>): <text lowercased, no trailing .>
_jrnl_build_subject() {
  local scope=""
  local message=""
  local word
  for word in "$@"; do
    case "$word" in
      [@#]*)
        [ -z "$scope" ] && scope="${word#?}"
        ;;
      *)
        message="${message:+$message }$word"
        ;;
    esac
  done
  message=$(printf '%s' "$message" | tr '[:upper:]' '[:lower:]')
  message="${message%.}"
  if [ -n "$scope" ]; then
    printf 'jrnl(%s): %s\n' "$scope" "$message"
  else
    printf 'jrnl: %s\n' "$message"
  fi
}

# stage all and commit; returns nonzero (skips push) when nothing changed
_jrnl_commit() {
  local dir=$1
  local subject=$2
  git -C "$dir" add -A
  git -C "$dir" diff --cached --quiet && return 1
  git -C "$dir" commit -q -m "$subject"
}

# push in the background (subshell so no job-control message); logged
_jrnl_push_remote() {
  local dir=$1
  local logfile=$2
  local subject=$3
  _jrnl_has_origin "$dir" || return 0
  (
    {
      printf '[%s] push %s\n' "$(date '+%F %T')" "$subject"
      git -C "$dir" push -q -u origin HEAD
      printf -- '---\n'
    } >>"$logfile" 2>&1 &
  )
}
