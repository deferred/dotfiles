#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'reconcile-spaces.sh'
# Builds a throwaway copy of the yabai config whose three steps are stubs, so
# the orchestration can be exercised without touching the real window server.
setup() {
	WORK_DIR="$(mktemp -d)"
	# No trailing slash. macOS sets one, most other systems do not, and the
	# runtime paths must come out the same either way.
	export TMPDIR="$WORK_DIR/tmp"
	mkdir -p "$TMPDIR"

	cp "$YABAI_SRC/executable_reconcile-spaces.sh" "$WORK_DIR/reconcile-spaces.sh"
	cp -R "$YABAI_SRC/lib" "$WORK_DIR/lib"
	chmod +x "$WORK_DIR/reconcile-spaces.sh"

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
}

cleanup() { rm -rf "$WORK_DIR"; }
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

lock_dir() { echo "$TMPDIR/yabai-reconcile.lock.d"; }
pending_file() { echo "$TMPDIR/yabai-reconcile.pending"; }

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

It 'releases the lock when it finishes'
When run reconcile
The status should be success
The output should be present
The stderr should equal ''
The path "$(lock_dir)" should not be exist
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

Describe 'the coalescing lock'
Context 'when another reconciliation holds the lock'
hold_lock() {
	mkdir -p "$(lock_dir)"
	echo $$ >"$(lock_dir)/pid"
}
Before 'hold_lock'

It 'queues a rerun instead of running concurrently'
When run reconcile
The status should be success
The stderr should equal ''
The output should include 'queueing a rerun'
The output should not include 'ran-setup-spaces'
The path "$(pending_file)" should be exist
End
End

Context 'when an event arrives mid run'
# `lockf -t 0` used to drop this event outright, losing the retry that
# recovered from a failed first pass.
queue_during_run() {
	# queue exactly one rerun, on the first pass only
	stub_step setup-spaces 0 "
				marker=\"$WORK_DIR/queued-once\"
				if [ ! -e \"\$marker\" ]; then
					touch \"\$marker\" \"$(pending_file)\"
				fi
			"
}
Before 'queue_during_run'

It 'reruns the whole reconciliation once'
When run reconcile
The status should be success
The output should include 'rerunning reconciliation for a queued display event'
The stderr should equal ''
End

It 'clears the pending marker afterwards'
When run reconcile
The status should be success
The output should be present
The stderr should equal ''
The path "$(pending_file)" should not be exist
End
End

Context 'when events keep arriving forever'
# Without a cap the rerun loop would spin for as long as events land.
always_queue() {
	stub_step setup-spaces 0 "touch \"$(pending_file)\""
	export RECONCILE_MAX_RUNS=2
}
Before 'always_queue'

It 'stops after the cap and drops the backlog'
When run reconcile
The status should be success
The output should include 'ran-setup-spaces'
The stderr should include 'reached 2 reconciliations, dropping queued events'
The path "$(pending_file)" should not be exist
End
End

Context 'when the cap is set below one'
# A bad value used to skip the loop body entirely and exit 0, so a display
# change reconciled nothing at all and said nothing about it.
zero_cap() { export RECONCILE_MAX_RUNS=0; }
Before 'zero_cap'

It 'still reconciles once'
When run reconcile
The status should be success
The output should include 'ran-setup-spaces'
The output should include 'ran-register-rules'
The output should include 'ran-apply-app-spaces'
End
End

Context 'when a previous run died and left its lock behind'
stale_lock() {
	mkdir -p "$(lock_dir)"
	echo 999999 >"$(lock_dir)/pid"
	touch -t 202001010000 "$(lock_dir)"
}
Before 'stale_lock'

It 'removes the stale lock and runs'
When run reconcile
The status should be success
The stderr should include 'removing stale lock from pid 999999'
The output should include 'ran-setup-spaces'
End
End

Context 'when a lock has no pid file yet'
# The owner may not have written its pid between mkdir and the write.
fresh_lock() {
	mkdir -p "$(lock_dir)"
}
Before 'fresh_lock'

It 'treats the lock as held rather than stealing it'
When run reconcile
The status should be success
The output should include 'queueing a rerun'
The output should not include 'ran-setup-spaces'
The stderr should equal ''
End
End
End
End
