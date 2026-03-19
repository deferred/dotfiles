---
name: create-worktree
description: >
  Create a new git worktree using the Worktrunk CLI (`wt`). Use this skill when
  the user asks to create a worktree, set up a new branch in a worktree, says
  "new worktree", "create worktree", "spin up a worktree", "work on X in a
  separate worktree", or anything related to creating or initializing git
  worktrees with wt/worktrunk.
---

# Create Worktree

Use the Worktrunk CLI `wt` to create a new worktree with a fresh branch.

## Workflow

1. **Ask for a branch name** if the user didn't provide one.

2. **Fetch the latest**:
   ```bash
   git fetch origin
   ```

3. **Create the worktree**:
   ```bash
   wt switch --create <branch-name> --base origin/HEAD --yes
   ```

   **Critical:** `wt switch` cannot change the agent's working directory. Parse
   the worktree path from `git worktree list` output and use it as `workdir` for
   all subsequent bash commands.

4. **Confirm** — verify the new worktree appears and report back to the user:
   ```bash
   git worktree list
   ```
