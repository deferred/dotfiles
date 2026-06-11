---
name: jrnl
description: >
  Log accomplishments, learnings, and notes using the `jrnl` CLI. Use this skill
  whenever the user asks to journal, log, note, jot down, or record what they did,
  learned, or accomplished — e.g. "journal that I fixed the deploy", "log this",
  "note that I learned X", "add to my journal". Always write via the `jrnl` command,
  never to a plain file, and apply the right tag.
---

When the user asks to journal/log something, write it with the `jrnl` CLI to the default journal. Pick the tag from intent and append it to the end of the entry text.

## Tags

- `@did` — something done or accomplished ("shipped the retry fix", "deployed v2")
- `@til` — today I learned / a new fact or insight
- `@work` — work-related; add alongside `@did`/`@til` when the entry is about the job

Tags combine. A work learning gets `@til @work`. A work accomplishment gets `@did @work`.

## Command

```sh
jrnl <entry text> <tags>
```

Pass the entry as command args (no editor). jrnl uses the default journal, timestamps automatically.

End the entry sentence with a period before the tags. jrnl treats the first sentence as the title, so a period keeps tags out of the title and listings clean.

## Examples

**Input:** journal that I fixed the flaky deploy pipeline at work
**Command:** `jrnl Fixed the flaky deploy pipeline. @did @work`

**Input:** note that I learned k8s readiness probe failures evict pods silently
**Command:** `jrnl k8s readiness probe failures evict pods silently — check events first. @til`

**Input:** log that I learned about jrnl tagging while setting up my work journal
**Command:** `jrnl Learned jrnl tagging while setting up my journal. @til @work`

## Notes

- If intent is ambiguous, ask which tag (one line) rather than guessing.
- Don't invent tags. Use only the ones described above.
- Retrieve later with `jrnl @til`, `jrnl @did @work`, `jrnl --tags`.
