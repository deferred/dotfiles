---
name: openspec
description: >
  Guidelines for working with OpenSpec. Use this skill whenever any action with
  OpenSpec is performed.
---

# OpenSpec

- Write artifacts short and on point, don't write filler.
- In `tasks.md`, give a fresh agent enough context to understand each task's goal,
  requirements, constraints, and expected result, then implement it correctly.
- Keep `tasks.md` aligned with the current implementation plan. Revise or replace
  existing tasks when the plan changes; add tasks only for genuinely new work.
- This skill explicitly authorizes `gwip` to create WIP commits. Run the `gwip` zsh
  alias after each artifact is created and after each task from `tasks.md` is done;
  do not ask for separate commit approval.
- Name `spec.md` dirs by capability, not by implementation detail. Not `sorrel-metallb`, but
  `sorrel-load-balancing`. Not `sorrel-netbootxyz`, but `sorrel-pxe-boot`.
