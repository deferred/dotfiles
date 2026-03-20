---
name: markdown-style-guide
description: >
  Write and revise Markdown so it is clean, scannable, and consistent. Use this
  skill whenever you are about to produce Markdown of any kind, including
  READMEs, docs, guides, notes, reports, issue bodies, pull request text, or
  comments, even if the user did not explicitly ask for Markdown formatting.
---

# Markdown Style Guide

## Break long lines

- Wrap lines at 120 characters, not 80 characters.
- Break lines at natural points such as sentences, clauses, or phrases.
- Prefer soft wrapping when possible so the source stays semantically clean.
- Use semantic line breaks when they make editing easier.
- Convert long inline links to reference-style links.

```md
Instead of:
Check out [this very long link text](https://example.com/very/long/path/to/resource)

Use:
Check out [this very long link text][1]

[1]: https://example.com/very/long/path/to/resource
```
