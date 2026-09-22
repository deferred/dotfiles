---
name: github-pr
description: >
  Use when creating, reviewing, commenting on, or closing GitHub pull requests.
---

# GitHub

## Create pull requests

- Read `references/pull-request-template.md` and use its contents when creating or updating a pull request.
- Put the Jira key in square brackets so the GitHub for Atlassian app can turn it into a native link.
- Do not put the Jira key in the PR title or branch name.
- Do not repeat requirements or acceptance criteria from Jira.
- Do not describe changes that are clear from the diff.

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

## Close pull requests

Before closing an unmerged pull request, always leave a comment that explains why it is being closed.
Include the context needed for a future reader to understand the decision. If another pull request supersedes it, link every
superseding pull request with its full URL and explain the relationship.

Do not use a vague reason such as "obsolete" without more context. If the reason or replacement is not known, ask the user
instead of inventing it.

```sh
gh pr close {number} --comment 'Closing because <reason>. <context>. Superseded by <full PR URL>.'
```
