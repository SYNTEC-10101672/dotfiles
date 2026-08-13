---
name: openspec-apply-change
description: Implement tasks from an OpenSpec change. Use when the user wants to start implementing, continue implementation, or work through tasks.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.3.1"
---

Implement tasks from an OpenSpec change.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, run `openspec list --json` to get available changes and use the **AskUserQuestion tool** to let the user select

   Always announce: "Using change: <name>" and how to override (e.g., `/opsx:apply <other>`).

2. **Check status to understand the schema**
   ```bash
   openspec status --change "<name>" --json
   ```
   Parse the JSON to understand:
   - `schemaName`: The workflow being used (e.g., "spec-driven")
   - Which artifact contains the tasks (typically "tasks" for spec-driven, check status for others)

3. **Get apply instructions**

   ```bash
   openspec instructions apply --change "<name>" --json
   ```

   This returns:
   - `contextFiles`: artifact ID -> array of concrete file paths (varies by schema - could be proposal/specs/design/tasks or spec/tests/implementation/docs)
   - Progress (total, complete, remaining)
   - Task list with status
   - Dynamic instruction based on current state

   **Handle states:**
   - If `state: "blocked"` (missing artifacts): show message, suggest using openspec-continue-change
   - If `state: "all_done"`: congratulate, suggest archive
   - Otherwise: proceed to implementation

4. **Read context files**

   Read every file path listed under `contextFiles` from the apply instructions output.
   The files depend on the schema being used:
   - **spec-driven**: proposal, specs, design, tasks
   - Other schemas: follow the contextFiles from CLI output

5. **Show current progress**

   Display:
   - Schema being used
   - Progress: "N/M tasks complete"
   - Remaining tasks overview
   - Dynamic instruction from CLI

5.5. **Unit test assessment (at apply start)**

   Fire `explore` (`run_in_background=true`) to scan the codebase and assess which implementation tasks warrant unit tests (based on complexity, branching logic, pure functions, etc.). Wait for explore results before proceeding.

   If valuable test opportunities are found, use AskUserQuestion to ask the user whether to add T* items to the `## 測試` section of tasks.md.

   Based on user response: add corresponding T* items to tasks.md, or skip and continue implementation.

6. **TDD three-phase implementation flow**

   **Red phase (before implementation)**:
   - Invoke `openspec-tdd-verify` skill with Red phase; run all T* items from the `## 測試` section of tasks.md
   - Confirm all T* are failing (expected to fail)
   - If any T* already passes, report and ask the user whether to continue

   **Per-task implementation (Green phase)**:

   For each task to implement:
   - Show the current task being worked on
   - Make minimal code changes
   - After implementation, invoke `openspec-tdd-verify` skill with Green phase; run the corresponding T* (marked with `→ T<n>`)
   - Once T* passes, change the task's `- [ ]` to `- [x]` in tasks.md
   - Proceed to the next task

   **Final phase (after all implementation complete)**:
   - Invoke `openspec-tdd-verify` skill with Final phase; run all T* items
   - Confirm all T* pass

   **Pause if:**
   - Task is unclear → fire `explore` (`run_in_background=true`) to research codebase context, then decide
   - Need external API/library info → fire `librarian` (`run_in_background=true`)
   - Stuck on a design decision → fire `oracle` for consultation
   - Above options exhausted without resolution → ask the user
   - Implementation reveals a design issue → suggest updating artifacts
   - Error or blocker encountered → report and wait for guidance
   - User interrupts

7. **Code Review (after Final phase passes)**

   **Trigger condition**: All T* pass Final phase.

   Invoke `openspec-code-review` skill to review the diff with parallel sub-agents.

   **Handle findings**:

   - **Standards axis CRITICAL** (violates CLAUDE.md / major Fowler smell):
     Ask the user whether to fix. If yes → enter fix loop.
   - **Spec axis CRITICAL** (spec requirement missing / scope creep):
     Pause, ask the user whether to add implementation or revise spec.
   - **WARNING / SUGGESTION**: list but don't block, let user decide.

   **Fix Loop (if any CRITICAL is fixed)**:

   a. Apply fix
   b. Re-invoke `openspec-tdd-verify` skill with Final phase
      (to avoid refactor breaking tests)
   c. All green → proceed to Step 8
   d. Still failing → return to fix loop

8. **On completion or pause, show status**

   Display:
   - Tasks completed this session
   - Overall progress: "N/M tasks complete"
   - If all done: suggest archive
   - If paused: explain why and wait for guidance

**Output During Implementation**

```
## Implementing: <change-name> (schema: <schema-name>)

Working on task 3/7: <task description>
[...implementation happening...]
✓ Task complete

Working on task 4/7: <task description>
[...implementation happening...]
✓ Task complete
```

**Output On Completion**

```
## Implementation Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 7/7 tasks complete ✓

### Completed This Session
- [x] Task 1
- [x] Task 2
...

All tasks complete! Ready to archive this change.
```

**Output On Pause (Issue Encountered)**

```
## Implementation Paused

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 4/7 tasks complete

### Issue Encountered
<description of the issue>

**Options:**
1. <option 1>
2. <option 2>
3. Other approach

What would you like to do?
```

**Guardrails**
- Keep going through tasks until done or blocked
- Always read context files before starting (from the apply instructions output)
- If task is ambiguous, pause and ask before implementing
- If implementation reveals issues, pause and suggest artifact updates
- Keep code changes minimal and scoped to each task
- Update task checkbox immediately after completing each task
- Pause on errors, blockers, or unclear requirements - don't guess
- Use contextFiles from CLI output, don't assume specific file names

**Fluid Workflow Integration**

This skill supports the "actions on a change" model:

- **Can be invoked anytime**: Before all artifacts are done (if tasks exist), after partial implementation, interleaved with other actions
- **Allows artifact updates**: If implementation reveals design issues, suggest updating artifacts - not phase-locked, work fluidly
