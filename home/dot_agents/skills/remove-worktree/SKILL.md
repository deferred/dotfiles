---
name: remove-worktree
description: >
  Remove git worktrees using the Worktrunk CLI `wt`. Use this skill when the user asks to "remove a
  worktree", "delete a worktree", "clean up a worktree", "remove branch worktree", or wants to get rid
  of a parallel development environment. Also trigger when the user mentions removing or deleting
  worktrees in any form.
---

# Remove Worktree

Use the Worktrunk CLI `wt` to remove git worktrees.

## Steps

1. **Identify the target worktree** from the user's request.

2. **Confirm** which worktree to remove only if the target is unclear. If it is obvious from context,
   such as "remove the feature-x worktree", proceed without asking.

3. **Run the removal**:
   ```bash
   wt remove <branch> --foreground
   ```
   Omit `<branch>` to remove the current worktree.

4. **Handle failures**. If the command fails, suggest the appropriate flag:
   - Untracked files (build artifacts, IDE config): add `--force` (`-f`)
   - Unmerged branch commits: add `--force-delete` (`-D`)
   - Both issues: add both flags

   Always explain what the flag does before running with it, so the user can make an informed call.

5. **Verify** the command succeeded and report the result to the user.

## Useful flags

| Flag | When to use |
| --- | --- |
| `--force` / `-f` | Worktree has untracked files (will not affect the branch) |
| `--force-delete` / `-D` | Branch has unmerged commits |
| `--no-delete-branch` | Keep the branch after removing the worktree |
| `--foreground` | Wait for completion (recommended when running as an agent) |

By default, `wt remove` also deletes the branch if it is already merged. That is usually what you want.
Use `--no-delete-branch` if the user wants to keep the branch.
