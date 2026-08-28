---
name: openspec-tdd-verify
description: Execute TDD verification for OpenSpec tasks using T* items with structured Command/Expected fields. Supports Red phase (before impl), Green phase (after each task), and Final phase (all tests).
---

Execute verification of T* items in the tasks.md `## Tests` block; mark `[x]` based on results.

**Input**: phase (Red / Green / Final) and corresponding T* numbers, or infer from context.

**Steps**

1. **Identify phase and target T* items**

   Determine the phase from context:
   - **Red phase**: before apply begins, run all T* to confirm they fail
   - **Green phase**: after completing an implementation task, run the corresponding T*
   - **Final phase**: after all implementation is done, run all T* to confirm they pass

   Read target T* items from the `## Tests` block in tasks.md.

   **If tasks.md uses the legacy `> 驗證：` inline format**:
   - Warn that this format is deprecated
   - Output: `⚠ tasks.md uses the legacy \`> 驗證：\` inline format. Update to the T* format (\`## Tests\` block with \`> Command:\` and \`> Expected:\` fields) before running verification.`
   - Stop

2. **Self-assess verification feasibility**

   For each T* item, evaluate whether `> Command:` can be executed directly:
   - **Explicit shell command** → execute directly, proceed to step 3
   - **Involves UI, network, or special environment** → propose 1-2 alternative verification approaches and ask the user (e.g. log inspection, API call, starting a local service); wait for confirmation before deciding how to verify
   - **T* contains `> Note: manual verification`** → jump to step 5

3. **Execute verification command**

   Run the T* `> Command:`; capture full output and exit code.

4. **Compare expected result**

   Compare the command output against `> Expected:`:

   **Red phase pass (= test fails, as expected)**:
   - Continue to the next T*
   - If a T* already passes in Red phase (= test passes, unexpected for Red):
     - Output warning: `⚠ T<n> already passes in Red phase — tests should fail before implementation. Confirm whether to continue.`
     - Ask the user whether to continue

   **Green / Final phase pass (= test passes)**:
   - Change the T* `- [ ]` to `- [x]` in tasks.md
   - Output: `✓ T<n> passed → marked [x]`

   **Green / Final phase fail (= test fails)**:
   - Do not mark `[x]`
   - Output failure details: the diff between command output and `> Expected:`
   - Pause and wait for user instruction

5. **Manual verification (confirmed not auto-executable)**

   - Output: `⚠ Manual verification: <description of what the user needs to confirm>`
   - Change the T* `- [ ]` to `- [x]` (with annotation)
   - Continue to the next T*

6. **Output summary**

   After running all target T* items, output a summary:
   ```
   ## Verification summary (<phase> phase)

   ✓ T1 passed
   ✓ T2 passed
   ✗ T3 failed (see details above)

   Passed: 2/3  Failed: 1/3
   ```
