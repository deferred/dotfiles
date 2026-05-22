#!/usr/bin/env bash
# Keep only the N most recent tmux-resurrect save files.
# Called by tmux-resurrect post-save hook.
RESURRECT_DIR="${HOME}/.local/share/tmux/resurrect"
KEEP=20
ls -t "${RESURRECT_DIR}"/tmux_resurrect_*.txt 2>/dev/null | tail -n +$((KEEP + 1)) | xargs rm -f 2>/dev/null || true
