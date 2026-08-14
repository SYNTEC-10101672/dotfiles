---
name: "OPSX: Re-verify"
description: Reset all T* items in tasks.md ## Tests block and re-run Final phase verification. Use after /simplify (refactor) to confirm all tests still pass.
category: Workflow
tags: [workflow, tdd, verify]
---

After a refactor (`/simplify`), re-verify all T* items in the tasks.md `## Tests` block.

**Steps**

1. **Find the tasks.md for the current change**

   Run `openspec list --json` to get the active change, then read its tasks.md.

   If multiple active changes exist, use the **AskUserQuestion tool** to let the user select.

2. **Reset all T* items in the `## Tests` block**

   Change all `- [x]` back to `- [ ]` in the `## Tests` block.

   **Only process the `## Tests` block** — the `## Implementation` block's task status stays unchanged.

3. **Execute Final phase verification**

   Use the `openspec-tdd-verify` skill to execute **Final phase** verification on all T* items.
