---
name: markdown
description: >
  Use this skill whenever working with Markdown files.
---

# Markdown

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
