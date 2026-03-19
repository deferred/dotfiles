---
name: remove-worktree
description: >
  Remove git worktrees using the Worktrunk`wt  CLI. Use this skill when the user asks
  to "remove a worktree", "delete a worktree", "clean up a worktree", "remove branch
  worktree", or wants to get rid of a parallel development environment. Also trigger when
  the user says `wt remove`, wants to clean up after merging a branch, or mentions
  removing/deleting worktrees in any form.
---

# Remove Worktree

Use the Worktrunk `wt` CLI to remove git worktrees.

## Steps

1. **Show current worktrees** so you and the user have context:
   ```
   git worktree list
   ```

2. **Confirm** with the user which worktree(s) to remove. If it's obvious from context (e.g., they said "remove the feature-x worktree"), just confirm once before proceeding — don't ask unnecessarily.

3. **Run the removal** with `--foreground` so you can see the result:
   ```
   wt remove <branch> --foreground
   ```
   Omit `<branch>` to remove the current worktree.

4. **Handle failures** — if the command fails, suggest the appropriate flag:
   - Untracked files (build artifacts, IDE config): add `--force` (`-f`)
   - Unmerged branch commits: add `--force-delete` (`-D`)
   - Both issues: add both flags

   Always explain what the flag does before running with it, so the user can make an informed call.

5. **Verify** the worktree is gone:
   ```
   git worktree list
   ```

## Useful flags

| Flag | When to use |
|------|-------------|
| `--force` / `-f` | Worktree has untracked files (won't affect the branch) |
| `--force-delete` / `-D` | Branch has unmerged commits |
| `--no-delete-branch` | Keep the branch after removing the worktree |
| `--foreground` | Wait for completion (recommended when running as an agent) |

By default `wt remove` also deletes the branch if it's already merged — that's usually what you want. Use `--no-delete-branch` if the user wants to keep the branch.
