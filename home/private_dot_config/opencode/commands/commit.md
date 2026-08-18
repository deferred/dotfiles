---
description: Git commit
---

Analyze the commit and use a `fast` subagent to load the `git-commit` skill and
execute it.

The calling agent owns the reasoning. Before invoking `fast`, determine and pass:

- The exact files allowed in each commit
- The grouping of those files into commits
- The Conventional Commit type, scope, and description for each commit
- Any body or footer to include
- Relevant session context, rationale, and issue references
- Arguments, if any: $ARGUMENTS

The `fast` subagent must treat that plan as authoritative. It should verify the
worktree, diff, staged changes, and secrets before committing, but must not infer
a broader scope, regroup files, or generate a different message.

Commit only files worked on in this session. Do not blindly commit everything already staged.

Create multiple commits only when the calling agent's plan specifies isolated
logical units.

If the calling agent did not provide a complete, unambiguous plan, ask one short
clarifying question instead of deciding the scope or grouping yourself.
