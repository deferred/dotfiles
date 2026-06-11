---
name: jrnl
description: >
  Log accomplishments, learnings, and notes using the `jrnl` CLI. Use this skill
  whenever the user asks to journal, log, note, jot down, or record what they did,
  learned, or accomplished — e.g. "journal that I fixed the deploy", "log this",
  "note that I learned X", "add to my journal". Always write via the `jrnl` command,
  never to a plain file, and confirm text and tags with the user before writing.
---

When the user asks to journal/log something, don't write immediately. First draft a cleaned-up entry,
then confirm text and tags via the interactive question/selection tool (AskUserQuestion / Question),
then run `jrnl`.

## Step 1 — draft

Turn what the user said into a concise entry sentence. Infer likely tags from intent.

## Step 2 — confirm via selection window

Open ONE window with two questions:

1. **Entry** (single choice): present the drafted text as the option. The tool auto-adds a "type your own"
   option so the user can rewrite it.
2. **Tags** (multiple choice, `multiple: true`): list the inferred tags first with a `(suggested)` label,
   then the remaining ones from `@did`/`@til`/`@work`. The tool can't pre-check options, so suggested ordering
   plus labels guide the choice. The auto-added "type your own" lets the user add another tag. If the user
   selects no tags, fall back to the tags you inferred.

Tag meanings:

- `@did` — something done or accomplished
- `@til` — today I learned / a new insight
- `@work` — work-related; combine with `@did`/`@til`

## Step 3 — write

Compose and run:

```sh
jrnl <chosen text>. <chosen tags>
```

End the entry sentence with a period before the tags. jrnl treats the first sentence as the title,
so the period keeps tags out of the title and listings clean.

## Skip the window

If the user says "just log it", "no prompt", or similar, skip Step 2 and write directly with your drafted
text and inferred tags.

## Notes

- Propose only `@did`/`@til`/`@work` yourself; additional tags come from the user's own selection, not invented by you.
- jrnl uses the default journal and timestamps automatically.
- Retrieve later with `jrnl @til`, `jrnl @did @work`, `jrnl --tags`.
