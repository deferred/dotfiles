---
description: Git commit
---

Use a `general` subagent to load the "git-commit" skill and create the commit.

Pass the subagent:

- Arguments, if any: $ARGUMENTS
- Relevant session context needed to infer the commit scope and grouping

The subagent must infer the commit scope and grouping from the provided arguments and context.

Commit only files worked on in this session. Do not blindly commit everything already staged.

Create multiple commits when the changes are isolated logical units.

Use a commit body when it preserves useful context: what problem was being solved, why it was done, and why this approach
was chosen.

If the scope or grouping is ambiguous, ask one short clarifying question before making commits.
