---
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

## Commit handoff

This environment forbids AI-run `git commit`. After code-review passes:

1. Stage the changed files by explicit path (never `git add .` or `git add -A`); leave build artifacts, screenshots, and unrelated untracked files out.
2. Draft a commit message matching the repo's recent style (`git log --oneline -10`), including ticket references if the repo tracks tickets under `.scratch/`.
3. Tell the user the work is done and staged, and prompt them to run /commit to finalize.
