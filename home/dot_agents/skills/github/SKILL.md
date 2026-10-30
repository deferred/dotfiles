---
name: github
description: >
  Use this skill whenever working with GitHub: reviewing or commenting on pull requests, issues, commits, or
  discussions, or running any `gh` command or GitHub API call.
---

# GitHub

## Anchor comments to the code

Post code feedback as an inline review comment on the exact diff line, never as a top-level comment.
Use `start_line` for a range.

```sh
gh api --method POST repos/{owner}/{repo}/pulls/{number}/comments \
  -f body='This shadows the outer `config`.' \
  -f commit_id="$(gh pr view {number} --json headRefOid -q .headRefOid)" \
  -f path='src/server.py' -F line=42 -f side='RIGHT'
```

Top-level comments are only for feedback with no location, such as a summary or a missing file.
