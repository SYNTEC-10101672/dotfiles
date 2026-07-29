## 測試

- [x] T1 openspec-propose 反規則已刪除並替換為 fact-vs-decision
  > 指令：讀取 `~/.claude/skills/openspec-propose/SKILL.md`，搜尋第 108 行附近
  > 預期：找不到「prefer making reasonable decisions to keep momentum」；找到 "Distinguish facts from decisions" 規則文字（含 "Fact"、"Decision"、"Never substitute a pronoun for a fact" 等關鍵字）

- [x] T2 openspec-propose Step 4c 改為 fact/decision 觸發區分
  > 指令：讀取 `~/.claude/skills/openspec-propose/SKILL.md` 第 78-80 行附近
  > 預期：Step 4c 標題從「If an artifact requires user input (unclear context)」改為 "When to ask the user"，含三條規則文字：「Encountering a decision → use AskUserQuestion」、「Encountering a fact but cannot find it in codebase → also use AskUserQuestion」、「Never substitute a pronoun to skip the question」

- [x] T3 openspec-propose 新增 Step 5 Fact Lookup 與 Step 6 Self-Containment Gate（原 Step 5 改編號為 Step 7）
  > 指令：讀取 `~/.claude/skills/openspec-propose/SKILL.md`，確認 step 編號順序為 1→2→3→4→5(Fact Lookup)→6(Self-Containment Gate)→7(Show final status)
  > 預期：存在「5. **Fact Lookup - eliminate pronouns**」段落（含 vague references 清單、search codebase、found → inline replace、not found → list and ask user、cross-task shared 寫 design.md Context 段）；存在「6. **Self-Containment Gate - simulate fresh AI perspective**」段落（含三項檢查：file locatable、change concrete、completion criterion checkable + conceptual task 要附 schema/pseudocode）；原本的「Show final status」編號為 7

- [x] T4 openspec-code-review skill 已建立且含完整 5 步流程
  > 指令：讀取 `~/.claude/skills/openspec-code-review/SKILL.md`
  > 預期：檔案存在；包含 frontmatter（`name: openspec-code-review`、含 trigger 片段的 description）；包含 5 個步驟段落（Pin fixed point / Identify spec source / Identify standards sources / Spawn both sub-agents in parallel / Aggregate）

- [x] T5 openspec-code-review skill 有雙軸定義與 Fowler 12 baseline
  > 指令：讀取 `~/.claude/skills/openspec-code-review/SKILL.md` 的步驟 3 與步驟 4
  > 預期：Standards 來源包含 CLAUDE.md「程式碼規範」段 + Fowler 12 smells 完整列表（Mysterious Name / Duplicated Code / Feature Envy / Data Clumps / Primitive Obsession / Repeated Switches / Shotgun Surgery / Divergent Change / Speculative Generality / Message Chains / Middle Man / Refused Bequest）；步驟 4 含「Spawn 兩個 sub-agent 平行」與「Standards sub-agent brief」「Spec sub-agent brief」兩段 prose

- [x] T6 openspec-apply 新增 Step 7 觸發 code review + Fix Loop
  > 指令：讀取 `~/.claude/skills/openspec-apply-change/SKILL.md`，在第 75 行「6. **TDD 三階段實作流程**」之後
  > 預期：存在「7. **Code Review (after Final phase passes)**」段落，含「Trigger condition: All T* pass Final phase」「Invoke `openspec-code-review` skill」「CRITICAL handling logic (Standards / Spec)」「Fix Loop 4 步驟 (Apply fix / Re-invoke openspec-tdd-verify Final phase / All green → Step 8 / Still failing → return to fix loop)」

- [x] T7 openspec-apply 原 Step 7 改編號為 Step 8
  > 指令：讀取 `~/.claude/skills/openspec-apply-change/SKILL.md` 第 101 行附近
  > 預期：「On completion or pause, show status」前綴從「7.」改為「8.」

- [x] T8 CLAUDE.md 新增 3 條 OpenSpec 規範
  > 指令：讀取 `~/.claude/CLAUDE.md`，從第 45 行「## OpenSpec 規範」段開始讀
  > 預期：可見三條新規範文字：(1) 含「寫 tasks.md 時不可用代名詞描述環境事實，必須用具體值」；(2) 含「design.md 應包含 `### Context` 段落」；(3) 含「完成 `opsx:apply` 後，必須執行 `openspec-code-review`」

## 實作

- [x] 1.1 修改 `~/.claude/skills/openspec-propose/SKILL.md`：刪除第 108 行「- If context is critically unclear, ask the user - but prefer making reasonable decisions to keep momentum」，替換為以下規則文字（→ T1）：

  ```
  - Distinguish facts from decisions (inspired by Matt Pocock's grilling skill):
    - **Fact** (environment-discoverable: file paths, API names, IP/port, existing constants) → MUST look up in codebase / config, inline concrete value, never substitute with a pronoun
    - **Decision** (requires user judgment: algorithm choice, feature scope) → ask via AskUserQuestion
  - Prefer slowness over guessing. Never substitute a pronoun for a fact and continue.
  ```

- [x] 1.2 修改 `~/.claude/skills/openspec-propose/SKILL.md` 第 78-80 行 Step 4c：將原本「If an artifact requires user input (unclear context) / Use AskUserQuestion tool to clarify / Then continue with creation」三行，替換為以下內容（→ T2）：

  ```
  c. **When to ask the user**:
     - Encountering a decision → use AskUserQuestion
     - Encountering a fact but cannot find it in codebase → also use AskUserQuestion (label whether it's "external resource, please provide URL/IP" or "to be created")
     - Never substitute a pronoun to skip the question
  ```

- [x] 1.3 在 `~/.claude/skills/openspec-propose/SKILL.md` 第 82 行「5. **Show final status**」之前，新增兩個 top-level step（新 Step 5 與新 Step 6），並將原「5. **Show final status**」改編號為「7. **Show final status**」（→ T3）

  新 Step 5 完整文字為：
  ```
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
  ```

  緊接著新增 Step 6 完整文字為：
  ```
  6. **Self-Containment Gate - simulate fresh AI perspective**

     Switch to "pretend you haven't seen the session conversation" perspective. For each task, check:

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
  ```

- [x] 2.1 建立 `~/.claude/skills/openspec-code-review/SKILL.md`（全新檔案），完整內容如下（→ T4, T5）：

  ```markdown
  ---
  name: openspec-code-review
  description: Review a change's diff along two axes - Standards (CLAUDE.md code standards + Fowler smells baseline) and Spec (does it faithfully implement the OpenSpec change artifacts?). Runs both as parallel sub-agents. Use when openspec-apply completes, when the user wants to review a change, asks to "review since X", or mentions code review.
  ---

  Two-axis review of the diff since change started:

  - **Standards** - code follows repo conventions + avoids Fowler smells
  - **Spec** - faithfully implements proposal/specs/design/tasks

  Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

  ## Process

  ### 1. Pin the fixed point

  Use `git merge-base <change-start-commit> HEAD` as fixed point. Capture:
  - `git diff <fixed-point>...HEAD` (three-dot)
  - `git log <fixed-point>..HEAD --oneline`

  Confirm fixed point resolves and diff is non-empty.

  ### 2. Identify spec source

  OpenSpec change artifacts for current change:
  - `openspec/changes/<name>/proposal.md`
  - `openspec/changes/<name>/specs/<capability>/spec.md` (all delta specs)
  - `openspec/changes/<name>/design.md`
  - `openspec/changes/<name>/tasks.md`

  ### 3. Identify standards sources

  - `~/.claude/CLAUDE.md` "程式碼規範" section (code standards)
  - repo CODING_STANDARDS.md / CONTRIBUTING.md (if present)
  - Fowler 12 smells baseline (fixed, sub-agent always carries it):
    - Mysterious Name
    - Duplicated Code
    - Feature Envy
    - Data Clumps
    - Primitive Obsession
    - Repeated Switches
    - Shotgun Surgery
    - Divergent Change
    - Speculative Generality
    - Message Chains
    - Middle Man
    - Refused Bequest

  Rules:
  - Documented repo standard always overrides smell baseline
  - Each smell is a heuristic (labelled), not a hard violation
  - Skip anything tooling already enforces

  ### 4. Spawn both sub-agents in parallel (single message, 2 task calls)

  Use `general-purpose` subagent type for both.

  **Standards sub-agent** brief (include diff command, commit list, CLAUDE.md code standards section content, full Fowler 12 baseline list):
  ```
  Report - per file/hunk:
  (a) violations of CLAUDE.md code standards (cite rule)
  (b) Fowler smells spotted (name + quote hunk)
  Distinguish hard violations from judgement calls.
  When a documented repo standard exists, standard overrides smell baseline.
  Skip anything tooling enforces. Under 400 words.
  ```

  **Spec sub-agent** brief (include diff command, commit list, all OpenSpec change artifact paths or contents):
  ```
  Report:
  (a) requirements from proposal/specs/design that are missing or partial
  (b) behavior in the diff not asked for (scope creep)
  (c) implementation that looks wrong
  Quote the spec line for each finding. Under 400 words.
  ```

  ### 5. Aggregate

  Present under `## Standards` and `## Spec` headings, separately.
  **Do NOT merge or rerank findings** - the two axes are deliberately separate.

  End with: total findings per axis, worst issue per axis.
  Do not pick a single winner.

  ## Why two axes

  - Standards pass / Spec fail: beautiful code doing the wrong thing
  - Spec pass / Standards fail: correct behavior breaking conventions

  Reporting them separately stops one axis from masking the other.
  ```

- [x] 3.1 在 `~/.claude/skills/openspec-apply-change/SKILL.md` 第 75 行「6. **TDD 三階段實作流程**」段落之後（即 Step 6 結束、第 101 行「7. **On completion or pause, show status**」之前），新增 Step 7（→ T6）：

  完整文字為：
  ```
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
  ```

- [x] 3.2 修改 `~/.claude/skills/openspec-apply-change/SKILL.md` 第 101 行：將「7. **On completion or pause, show status**」改為「8. **On completion or pause, show status**」（→ T7）

- [x] 4.1 修改 `~/.claude/CLAUDE.md` 第 45 行「## OpenSpec 規範」段：在既有規範之後（即「使用 `opsx:apply` 完成每個 task 實作後，必須呼叫 `openspec-tdd-verify` skill 執行驗證，通過才 mark `[x]`」之後），新增以下 3 條規範（→ T8）：

  ```
  - 寫 tasks.md 時不可用代名詞描述環境事實，必須用具體值（例：「測試控制器」要寫成「127.0.0.1:8080 (config.dev.yaml)」）
  - design.md 應包含 `### Context` 段落，集中放跨 task 共用的環境事實（服務 URL、檔案路徑、既有 API 等）
  - 完成 `opsx:apply` 後，必須執行 `openspec-code-review`（雙軸 sub-agents）通過才能建議 archive；若 code-review 有 fix，fix 後必須重跑 Final phase tests 確認沒退化
  ```
