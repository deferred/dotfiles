#!/usr/bin/env bash
#
# gate continuum autosave to prevent the dark-wake save pileup that spikes load
# wired via @resurrect-save-script-path; manual prefix+C-s saves bypass this

REAL_SAVE="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"
PATTERN='tmux-resurrect/scripts/save.sh'

# skip autosave during dark wake (UserIsActive absent; reliable on Apple Silicon)
active="$(pmset -g assertions 2>/dev/null |
  sed -n 's/^[[:space:]]*UserIsActive[[:space:]]*\([0-9]\).*/\1/p' | head -1)"
[ "$active" = "1" ] || exit 0

# convert macOS ps etime ([[DD-]HH:]MM:SS) to seconds
etime_to_secs() {
  local t="$1" d=0
  case "$t" in *-*)
    d="${t%%-*}"
    t="${t#*-}"
    ;;
  esac
  local IFS=:
  set -- $t
  case $# in
  3) echo $((d * 86400 + 10#$1 * 3600 + 10#$2 * 60 + 10#$3)) ;;
  2) echo $((d * 86400 + 10#$1 * 60 + 10#$2)) ;;
  *) echo $((d * 86400 + 10#$1)) ;;
  esac
}

# reap saves hung >90s
for pid in $(pgrep -f "$PATTERN"); do
  e="$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ')"
  [ -n "$e" ] && [ "$(etime_to_secs "$e")" -gt 90 ] && kill -9 "$pid" 2>/dev/null
done

# skip if a save is still running to prevent stacking
pgrep -qf "$PATTERN" && exit 0

# exec so the save is tracked under PATTERN by the reap/skip checks above
exec "$REAL_SAVE" "$@"
