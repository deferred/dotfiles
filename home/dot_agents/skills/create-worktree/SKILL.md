---
name: create-worktree
description: >
  Create a new git worktree using the Worktrunk CLI `wt`. Use this skill when the user asks to create a
  worktree, set up a new branch in a worktree, says "new worktree", "create worktree", "work on X in a
  separate worktree", or anything related to creating or initializing git worktrees.
---

# Create Worktree

Use the Worktrunk CLI `wt` to create a new worktree with a fresh branch.

## Workflow

1. **Ask for a branch name** if the user did not provide one.

2. **Fetch the latest**:
   ```bash
   git fetch origin
   ```

3. **Create the worktree**:
   ```bash
   wt switch --create <branch-name> --base origin/HEAD --yes --no-cd
   ```

   **Critical:** `wt switch` cannot change the agent's working directory. Parse the worktree path from
   the command output and use it as `workdir` for all subsequent bash commands if the agent needs to
   work in the new worktree.

4. **Confirm**: report the created branch and worktree path back to the user.
