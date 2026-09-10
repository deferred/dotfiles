#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'window placement rules'
setup() {
	COMMANDS_FILE="$(mktemp)"
	RULES_JSON='[
			{"app":"^Slack$","space":0},
			{"app":"^Safari$","space":1},
			{"app":"^Alacritty$","space":2},
			{"app":"^Slack$","space":6},
			{"app":"^Telegram$","space":6},
			{"app":"^Spotify$","space":8}
		]'
}
cleanup() { rm -f "$COMMANDS_FILE"; }
BeforeEach 'setup'
AfterEach 'cleanup'

commands() { cat "$COMMANDS_FILE"; }

yabai() {
	if [ "${2:-}" = "rule" ] && [ "${3:-}" = "--list" ]; then
		echo "$RULES_JSON"
		return 0
	fi

	# the scripts set IFS=$'\n\t', so join the arguments explicitly
	local joined
	joined="$(
		IFS=' '
		echo "$*"
	)"
	echo "$joined" >>"$COMMANDS_FILE"

	# fail one specific command, the way yabai does on a transient error
	if [ -n "${YABAI_FAIL_ARG:-}" ] && [[ $joined == *"$YABAI_FAIL_ARG"* ]]; then
		return 1
	fi
	return "${YABAI_MUTATION_STATUS:-0}"
}

Describe 'register-rules.sh'
Include home/private_dot_config/yabai/executable_register-rules.sh

Describe 'remove_all_rules'
It 'removes one rule per entry, always at index 0'
When call remove_all_rules
The status should be success
The output should include 'removing 6 existing rules'
The result of function commands should equal '-m rule --remove 0
-m rule --remove 0
-m rule --remove 0
-m rule --remove 0
-m rule --remove 0
-m rule --remove 0'
End

Context 'when one removal fails'
# A transient yabai error must not leave stale rules behind, because a
# stale rule still maps a label to the old space index.
fail_one_removal() { YABAI_FAIL_ARG='--remove 0'; }
Before 'fail_one_removal'

It 'keeps removing the remaining rules'
When call remove_all_rules
The status should be success
The stdout should be present
The stderr should include '[WARN]'
The lines of result of function commands should equal 6
End
End
End

Describe 'register_rules'
# Rules must be added by label. yabai resolves a label to a space index at
# registration time, so re-registering after a display change is what keeps
# the mapping correct.
It 'sends the messaging apps to the messaging label'
When call register_rules
The status should be success
The result of function commands should include 'app=^Slack$ space=messaging'
The result of function commands should include 'app=^Telegram$ space=messaging'
The result of function commands should include 'app=^Microsoft Teams$ space=messaging'
End

It 'never hardcodes a numeric space'
When call register_rules
The status should be success
The result of function commands should not include 'space=6'
End

It 'keeps floating apps unmanaged'
When call register_rules
The status should be success
The result of function commands should include 'app=^Calculator$ manage=off'
The result of function commands should include 'app=^Slack$ subrole=AXSystemDialog manage=off'
End

Context 'when yabai rejects one rule'
fail_one_add() { YABAI_FAIL_ARG='app=^Steam$'; }
Before 'fail_one_add'

It 'warns and keeps registering the remaining rules'
When call register_rules
The status should be success
The stdout should be present
The stderr should include '[WARN]'
The result of function commands should include 'app=^Slack$ space=messaging'
The result of function commands should include 'app=^Spotify$ space=^music'
End
End
End
End

# `When call` runs with errexit off, so it cannot show what `set -e` does to
# the real script. Run it as a process instead.
Describe 'register-rules.sh as a process'
setup_process() {
	WORK_DIR="$(mktemp -d)"
	cp "$YABAI_SRC/executable_register-rules.sh" "$WORK_DIR/register-rules.sh"
	cp -R "$YABAI_SRC/lib" "$WORK_DIR/lib"
	chmod +x "$WORK_DIR/register-rules.sh"

	# a yabai that rejects one rule near the top of the list
	cat >"$WORK_DIR/yabai" <<'STUB'
#!/usr/bin/env bash
if [ "${2:-}" = "rule" ] && [ "${3:-}" = "--list" ]; then
	echo '[{"app":"^Slack$","space":6}]'
	exit 0
fi
echo "$*" >>"$COMMANDS_FILE"
case "$*" in
*'app=^Steam$'*) exit 1 ;;
esac
exit 0
STUB
	chmod +x "$WORK_DIR/yabai"

	COMMANDS_FILE="$WORK_DIR/commands"
	export COMMANDS_FILE
	PATH="$WORK_DIR:$PATH"
}
cleanup_process() { rm -rf "$WORK_DIR"; }
BeforeEach 'setup_process'
AfterEach 'cleanup_process'

process_commands() { cat "$COMMANDS_FILE"; }
register_rules_script() { "$WORK_DIR/register-rules.sh"; }

# The whole point of re-registering is to rebuild every label mapping. One
# transient failure used to abort the script and skip every later rule,
# leaving Slack and Telegram without a space.
It 'registers the rules that follow the failing one'
When run register_rules_script
The status should be success
The stdout should include 'done'
The stderr should include '[WARN]'
The result of function process_commands should include 'app=^Slack$ space=messaging'
The result of function process_commands should include 'app=^Spotify$ space=^music'
End
End

Describe 'apply-app-spaces.sh'
Include home/private_dot_config/yabai/executable_apply-app-spaces.sh

Describe 'apply_app_spaces'
# Rules only fire for new windows, so existing windows must be re-applied
# explicitly. This is the step that actually rescues a stranded Slack.
It 'applies every rule that targets a real space'
When call apply_app_spaces
The status should be success
The result of function commands should include '-m rule --apply app=^Slack$ space=6'
The result of function commands should include '-m rule --apply app=^Telegram$ space=6'
The result of function commands should include '-m rule --apply app=^Spotify$ space=8'
End

It 'skips manage=off rules, which carry space 0'
When call apply_app_spaces
The status should be success
The result of function commands should not include 'space=0'
End

It 'logs each application'
When call apply_app_spaces
The status should be success
The output should include 'applying space 6 to ^Slack$'
End

Context 'when a single move fails'
fail_moves() { YABAI_MUTATION_STATUS=1; }
Before 'fail_moves'

It 'keeps applying the remaining rules'
When call apply_app_spaces
The status should be success
The stdout should be present
The stderr should include '[WARN]'
The result of function commands should include '-m rule --apply app=^Spotify$ space=8'
End
End

Context 'when the rule list never parses'
break_list() {
	yabai() {
		if [ "${2:-}" = "rule" ] && [ "${3:-}" = "--list" ]; then
			printf '[{'
			return 1
		fi
	}
	YABAI_RETRIES=2
}
Before 'break_list'

It 'reports failure instead of applying garbage'
When call apply_app_spaces
The status should be failure
The stdout should be present
The stderr should include 'after 2 attempts'
The result of function commands should equal ''
End
End
End
End

Describe 'move-1password-windows.sh'
Include home/private_dot_config/yabai/executable_move-1password-windows.sh

WINDOWS_JSON='[
			{"id":1,"app":"1Password","can-resize":true,"is-floating":false},
			{"id":2,"app":"1Password","can-resize":false,"is-floating":false},
			{"id":3,"app":"1Password","can-resize":true,"is-floating":true},
			{"id":4,"app":"Slack","can-resize":true,"is-floating":false}
		]'

yabai() {
	if [ "${2:-}" = "query" ] && [ "${3:-}" = "--windows" ]; then
		echo "$WINDOWS_JSON"
		return 0
	fi
	(
		IFS=' '
		echo "$*"
	) >>"$COMMANDS_FILE"
	return "${YABAI_MUTATION_STATUS:-0}"
}

Describe 'move_1password_windows'
It 'moves only the resizable, non-floating main window'
When call move_1password_windows
The status should be success
The result of function commands should equal '-m window 1 --space productivity'
End

It 'leaves popups and other apps alone'
When call move_1password_windows
The status should be success
The result of function commands should not include 'window 2'
The result of function commands should not include 'window 3'
The result of function commands should not include 'window 4'
End
End
End
End
