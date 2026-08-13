---
name: "OPSX: Propose"
description: Propose a new change - create it and generate all artifacts in one step
category: Workflow
tags: [workflow, artifacts, experimental]
---

I'll create a change with artifacts:
- proposal.md (what & why)
- design.md (how)
- tasks.md (implementation steps)

---

**Input**: The argument after `/opsx:propose` is the change name (kebab-case), OR a description of what the user wants to build.

**Steps**

1. **If no clear input provided, ask what they want to build**

   Use the **AskUserQuestion tool** (open-ended, no preset options) to ask:
   > "What change do you want to work on? Describe what you want to build or fix."

   From their description, derive a kebab-case name (e.g., "add user authentication" → `add-user-auth`).

2. **Create the change directory**
   ```bash
   openspec new change "<name>"
   ```
   This creates a scaffolded change at `openspec/changes/<name>/` with `.openspec.yaml`.
   If the name already exists, ask whether to continue it or create a new one.

3. **Get the artifact build order**
   ```bash
   openspec status --change "<name>" --json
   ```
   Parse the JSON to get:
   - `applyRequires`: array of artifact IDs needed before implementation (e.g., `["tasks"]`)
   - `artifacts`: list of all artifacts with their status and dependencies

4. **Create artifacts in sequence until apply-ready**

   Use the **TodoWrite tool** to track progress through the artifacts.

   Loop through artifacts in dependency order (artifacts with no pending dependencies first):

   a. **For each artifact that is `ready` (dependencies satisfied)**:
      - Get instructions:
        ```bash
        openspec instructions <artifact-id> --change "<name>" --json
        ```
      - The instructions JSON includes:
        - `context`: Project background (constraints for you - do NOT include in output)
        - `rules`: Artifact-specific rules (constraints for you - do NOT include in output)
        - `template`: The structure to use for your output file
        - `instruction`: Schema-specific guidance for this artifact type
        - `outputPath`: Where to write the artifact
        - `dependencies`: Completed artifacts to read for context
      - Read any completed dependency files for context
      - Create the artifact file using `template` as the structure
      - Apply `context` and `rules` as constraints - but do NOT copy them into the file
      - Show brief progress: "Created <artifact-id>"

   b. **Continue until all `applyRequires` artifacts are complete**
      - After creating each artifact, re-run `openspec status --change "<name>" --json`
      - Check if every artifact ID in `applyRequires` has `status: "done"` in the artifacts array
      - Stop when all `applyRequires` artifacts are done

   c. **When to ask the user**:
      - Encountering a decision → use AskUserQuestion
      - Encountering a fact but cannot find it in codebase → also use AskUserQuestion (label whether it's "external resource, please provide URL/IP" or "to be created")
      - Never substitute a pronoun to skip the question

5. **Fact Lookup - eliminate pronouns**

   For each artifact just written (especially tasks.md), scan line-by-line to find:

   **Vague references**:
   - Demonstratives: this / that / the / some / its
   - Under-specified concept words: controller / service / setting / function / module (without concrete filename or API name)
   - Placeholders: <...> / appropriate / corresponding / relevant

   For each vague point:

   a. **Search codebase / config / docs** (grep / glob / read)
      Priority: .env / config.*.yaml / package.json / entry files

   b. **Found → inline replace**:
      - "test controller" → "test controller (127.0.0.1:8080, config.dev.yaml)"
      - "user service" → "src/services/user.ts createUser()"
      - "existing router" → "src/server.ts:42"

   c. **Not found → list and ask user**:
      Use AskUserQuestion to list all not-found items at once:
      > "The following items have no concrete value found in codebase:
      > 1. 'X' - external resource (please provide URL/IP) / to be created / other?
      > 2. 'Y' - ..."

   d. **Cross-task shared environment facts → write into design.md `### Context` section**:
      Avoid repeating the same IP/path in every task.

6. **Self-Containment Gate**

   Read each task as an AI that has not seen this conversation. Check:

   □ **Can the file to modify be located?**
     - Concrete path (src/auth.ts) or locatable description
       ("the service handling login, under src/services/")

   □ **Is the change concrete?**
     - Specific API / line number / change content
     - Not verbs like "rewrite" "optimize" "improve"

   □ **Is the completion criterion checkable?**
     - The corresponding T* can be executed
     - Or specific acceptance criteria (e.g. "calling POST /users with invalid token returns 401")

   Any No → go back to Step 5 to strengthen that task

   **Special note**: For "conceptual tasks" (e.g. designing new structure, new flow),
   require concrete schema / pseudocode / file structure,
   not just prose description.

7. **Show final status**
   ```bash
   openspec status --change "<name>"
   ```

<!-- CUSTOM: momus-plan-gate -->

8. **Plan-quality gate — Momus review**

   Invoke the Momus plan critic to review the generated artifacts.

   ```text
   task(subagent_type="momus", prompt="openspec/changes/<name>/")
   ```

   - **CRITICAL issues / NEEDS-REVISION**: revise the flagged artifacts, then re-invoke Momus. Loop until APPROVED.
   - **APPROVED**: proceed to Output.

<!-- /CUSTOM: momus-plan-gate -->

**Output**

After completing all artifacts, summarize:
- Change name and location
- List of artifacts created with brief descriptions
- What's ready: "All artifacts created! Ready for implementation."
- Prompt: "Run `/opsx:apply` to start implementing."
