#!/bin/bash
# Cycle wifi off->on when ethernet plug-in is detected.
# - wifi on at plug-in: off, sleep 2, on
# - wifi off at plug-in: do nothing
# - ethernet unplug: do nothing (silent)
# Triggered by LaunchAgent watching /Library/Preferences/SystemConfiguration.

# -e intentionally omitted: fail-soft on transient networksetup hiccups;
# next trigger will retry. pipefail surfaces silent failures inside pipes.
set -uo pipefail
PATH="/bin:/sbin:/usr/bin:/usr/sbin"

STATE_DIR="${HOME}/Library/Application Support/local.wifi-cycle-on-eth"
STATE_FILE="${STATE_DIR}/eth.state"
LOG_DIR="${HOME}/Library/Logs/local.wifi-cycle-on-eth"
LOG_FILE="${LOG_DIR}/log"
LOG_MAX_LINES=500   # rotate when log exceeds this
LOG_KEEP_LINES=200  # tail size after rotation
mkdir -p "$STATE_DIR" "$LOG_DIR"

log() { echo "$(date '+%F %T')  $*" >> "$LOG_FILE"; }
notify_cycle() {
  local where="$1"
  osascript -e "display notification \"\" with title \"Cycling Wi-Fi\" subtitle \"Ethernet up on ${where}\"" 2>/dev/null || true
}

# Rotate log when it grows past LOG_MAX_LINES, keeping last LOG_KEEP_LINES.
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)" -gt "$LOG_MAX_LINES" ]; then
  tail -n "$LOG_KEEP_LINES" "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

# Resolve the wifi BSD device (e.g. en0). On modern macOS,
# networksetup -get/-setairportpower expects the device, not the service name.
WIFI_DEV=$(networksetup -listallhardwareports \
  | awk '/Hardware Port: Wi-Fi/{getline; print $2; exit}')
if [ -z "$WIFI_DEV" ]; then
  log "error: no wifi device found"
  exit 0
fi

# Walk every non-Wi-Fi service. For each, look up its BSD device and check
# whether ifconfig reports "status: active". First match wins.
eth_active=inactive
eth_match=""
eth_svc=""
while IFS= read -r svc; do
  [ -z "$svc" ] && continue
  [ "$svc" = "Wi-Fi" ] && continue
  case "$svc" in
    \** ) continue ;;          # disabled service prefixed with *
  esac

  dev=$(networksetup -listnetworkserviceorder \
    | awk -v want=") ${svc}\$" '
        $0 ~ want { getline nxt; print nxt; exit }
      ' \
    | sed -nE 's/.*Device: ([^)]+)\).*/\1/p')

  [ -z "$dev" ] && continue

  if ifconfig "$dev" 2>/dev/null | grep -q 'status: active'; then
    eth_active=active
    eth_match="$svc ($dev)"
    eth_svc="$svc"
    break
  fi
done < <(networksetup -listallnetworkservices | tail -n +2)

prev=$(cat "$STATE_FILE" 2>/dev/null || echo inactive)
echo "$eth_active" > "$STATE_FILE"

# Only act on the eth up transition (inactive -> active).
# All other transitions (down, no-change) are silent.
if [ "$prev" = "inactive" ] && [ "$eth_active" = "active" ]; then
  wifi_power=$(networksetup -getairportpower "$WIFI_DEV" | awk '{print $NF}')
  log "eth up on $eth_match"
  if [ "$wifi_power" = "On" ]; then
    log "wifi on, cycling"
    notify_cycle "$eth_svc"
    networksetup -setairportpower "$WIFI_DEV" off
    sleep 2
    networksetup -setairportpower "$WIFI_DEV" on
    log "cycle done"
  else
    log "wifi off, skip cycling"
  fi
fi
