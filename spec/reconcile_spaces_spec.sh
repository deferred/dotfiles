#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'reconcile-spaces.sh'
# Builds a throwaway copy of the yabai config whose three steps are stubs, so
# the orchestration can be exercised without touching the real window server.
setup() {
	WORK_DIR="$(mktemp -d)"
	# No trailing slash. macOS sets one, most other systems do not, and the
	# runtime path must come out the same either way.
	export TMPDIR="$WORK_DIR/tmp"
	mkdir -p "$TMPDIR"

	install_yabai_config "$WORK_DIR"
	stub_step setup-spaces 0
	stub_step register-rules 0
	stub_step apply-app-spaces 0

	# a stable layout so wait_for_stable_layout returns after two reads
	cat >"$WORK_DIR/yabai" <<'STUB'
#!/usr/bin/env bash
case "$*" in
*"query --displays"*) echo '[{"index":1,"uuid":"A","frame":{"w":1,"h":1}}]' ;;
*"query --spaces"*) echo '[{"index":1,"label":"web","display":1}]' ;;
esac
STUB
	chmod +x "$WORK_DIR/yabai"

	# Record sleeps instead of serving them. The stability loop is built out
	# of one-second waits, and the suite must not pay for them.
	SLEEPS_FILE="$WORK_DIR/sleeps"
	export SLEEPS_FILE
	cat >"$WORK_DIR/sleep" <<'STUB'
#!/usr/bin/env bash
echo "$*" >>"$SLEEPS_FILE"
STUB
	chmod +x "$WORK_DIR/sleep"

	PATH="$WORK_DIR:$PATH"
	VICTIM_PID=""
}

cleanup() {
	[ -z "$VICTIM_PID" ] || kill "$VICTIM_PID" 2>/dev/null || true
	rm -rf "$WORK_DIR"
}
BeforeEach 'setup'
AfterEach 'cleanup'

# stub_step <name> <exit status> [extra shell]
stub_step() {
	{
		echo '#!/usr/bin/env bash'
		echo "echo ran-$1"
		echo "${3:-}"
		echo "exit $2"
	} >"$WORK_DIR/$1.sh"
	chmod +x "$WORK_DIR/$1.sh"
}

reconcile() { "$WORK_DIR/reconcile-spaces.sh"; }
sleeps() { cat "$SLEEPS_FILE"; }
pidfile() { echo "$TMPDIR/yabai-reconcile.pid"; }

# A process that blocks until it is killed, standing in for a reconciliation
# that is still running when the next display event arrives.
start_victim() {
	tail -f /dev/null &
	VICTIM_PID=$!
	echo "$VICTIM_PID" >"$(pidfile)"
}

Describe 'the happy path'
It 'runs the three steps in order'
When run reconcile
The status should be success
The stderr should equal ''
The output should include 'ran-setup-spaces'
The output should include 'ran-register-rules'
The output should include 'ran-apply-app-spaces'
End

It 'waits for the layout to settle first'
When run reconcile
The status should be success
The output should include 'layout stable'
The stderr should equal ''
End

# Two reads are needed before they can agree, so exactly one wait happens
# on a layout that is already settled.
It 'waits one second between stability reads'
When run reconcile
The status should be success
The output should include 'layout stable after 2 reads'
The result of function sleeps should equal '1'
End

It 'removes its pidfile when it finishes'
When run reconcile
The status should be success
The output should be present
The stderr should equal ''
The path "$(pidfile)" should not be exist
End
End

Describe 'when a step fails'
# The original bug: setup-spaces.sh died on a transient yabai error and took
# register-rules.sh and apply-app-spaces.sh down with it, so no window rule
# was ever re-applied.
Context 'and it is setup-spaces'
failing_setup() { stub_step setup-spaces 1; }
Before 'failing_setup'

It 'still registers rules and applies them'
When run reconcile
The status should be failure
The output should include 'ran-register-rules'
The output should include 'ran-apply-app-spaces'
The stderr should include 'setup-spaces.sh failed, continuing'
End
End

Context 'and it is register-rules'
failing_register() { stub_step register-rules 1; }
Before 'failing_register'

It 'still applies the rules'
When run reconcile
The status should be failure
The output should include 'ran-apply-app-spaces'
The stderr should include 'register-rules.sh failed, continuing'
End
End

Context 'and every step fails'
all_failing() {
	stub_step setup-spaces 1
	stub_step register-rules 1
	stub_step apply-app-spaces 1
}
Before 'all_failing'

It 'reports failure but runs everything'
When run reconcile
The status should be failure
The output should include 'ran-setup-spaces'
The output should include 'ran-register-rules'
The output should include 'ran-apply-app-spaces'
The stderr should include 'apply-app-spaces.sh failed'
End
End
End

Describe 'the newest event wins'
# Reconciliation is idempotent, so restarting beats queueing: the new run
# reads the layout that the newest display event produced.
Context 'when another reconciliation is still running'
Before 'start_victim'

# An empty stderr also proves the victim died: claim_run waits for it and
# warns when it outlives the SIGTERM.
It 'cancels it and reconciles anyway'
When run reconcile
The status should be success
The stderr should equal ''
The output should include "cancelled reconciliation $VICTIM_PID"
The output should include 'ran-setup-spaces'
End
End

Context 'when a previous run died without cleaning up'
stale_pidfile() { echo 999999 >"$(pidfile)"; }
Before 'stale_pidfile'

It 'ignores the stale pid and reconciles'
When run reconcile
The status should be success
The stderr should equal ''
The output should not include 'cancelled'
The output should include 'ran-setup-spaces'
End
End

Context 'when the pidfile holds the running pid'
# Belt and braces: a script must never kill itself.
It 'does not cancel itself'
When run reconcile
The status should be success
The output should not include 'cancelled'
The output should include 'ran-apply-app-spaces'
End
End
End
End
