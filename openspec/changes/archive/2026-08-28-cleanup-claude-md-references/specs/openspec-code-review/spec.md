# Delta Spec: openspec-code-review

## MODIFIED Requirements

### Requirement: 新增 openspec-code-review skill

系統 MUST 新增 skill `~/.claude/skills/openspec-code-review/SKILL.md`,提供雙軸平行 sub-agents 的 code review 能力。

skill description MUST 包含足夠 trigger 片段讓 model-invoked 自動觸發可行(包含「review a change」「review since」「code review」等 leading words)。

skill MUST 定義以下流程:

1. Pin the fixed point(使用 `git merge-base <change-start-commit> HEAD`)
2. Identify spec source(OpenSpec change artifacts:proposal / specs / design / tasks)
3. Identify standards sources(repo documented coding standards(CODING_STANDARDS.md / CONTRIBUTING.md)若有 + Fowler 12 smells baseline)
4. Spawn 兩個 sub-agents 平行(Standards + Spec,單一訊息 兩個 task 呼叫)
5. Aggregate 兩軸報告,MUST NOT 合併或重新排名

#### Scenario: skill 檔案存在且包含必要結構

- **WHEN** 讀取 `~/.claude/skills/openspec-code-review/SKILL.md`
- **THEN** MUST 包含 frontmatter(name, description)、雙軸定義、5 步流程、Fowler 12 smells baseline 列表

#### Scenario: skill 可被 openspec-apply 內部 prose invocation 觸發

- **WHEN** `openspec-apply-change` 的 Step 7 執行「呼叫 `openspec-code-review` skill」
- **THEN** skill MUST 被載入並執行雙軸 review

### Requirement: Code review 必須以雙軸平行 sub-agents 執行

`openspec-code-review` MUST 在單一訊息中同時 spawn 兩個 sub-agent(使用 `general-purpose` subagent type):

- **Standards sub-agent**:檢查 diff 是否違反 documented repo standards + Fowler 12 smells baseline。每條 finding 區分 hard violation vs judgement call。有 documented repo standard 時,standard 蓋過 smell baseline。略過 tooling 已強制的東西。400 字內。
- **Spec sub-agent**:檢查 diff 是否 faithful 實作 OpenSpec change artifacts(proposal / specs / design / tasks)。找出「spec 要求但缺漏」「scope creep」「實作錯誤」。每條 quote spec line。400 字內。

兩軸報告 MUST 各自獨立呈現(`## Standards` 與 `## Spec`),MUST NOT 合併或重新排名。

#### Scenario: 兩個 sub-agent 平行執行

- **WHEN** `openspec-code-review` 進入 Step 4(spawn sub-agents)
- **THEN** MUST 在單一 assistant message 中同時發出兩個 task tool call(不可序列執行)

#### Scenario: 兩軸報告分開呈現

- **WHEN** aggregate 階段產出最終報告
- **THEN** 報告 MUST 有「## Standards」與「## Spec」兩個獨立段,MUST NOT 有「合併排名」或「單一 winner」

## REMOVED Requirements

### Requirement: Standards 軸必須使用 CLAUDE.md + Fowler 12 baseline

**Reason**: system prompt（全域指示檔）是 generation-time 約束，不是 repo documented 的審查契約；skill 引用永遠已載入的材料是零功 pointer，且違反 `skill-self-containment` capability。與上游（mattpocock/skills `code-review`）設計對齊。

**Migration**: 由下方 ADDED requirement「Standards 軸必須使用 documented repo standards + Fowler 12 baseline」取代。行為差異：Standards 軸不再檢查全域「程式碼規範」（註解英文、最小變更）— 前者由 generation-time system prompt 約束，後者的 diff 面向（scope creep）由 Spec 軸涵蓋。

## ADDED Requirements

### Requirement: Standards 軸必須使用 documented repo standards + Fowler 12 baseline

Standards sub-agent 的標準來源 MUST 為:

1. repo CODING_STANDARDS.md / CONTRIBUTING.md(若存在)
2. 固定 Fowler 12 smells baseline(sub-agent 必帶,無論 repo 是否有文件):
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

來源清單 MUST NOT 包含全域指示檔(`~/.claude/CLAUDE.md` / `~/.config/opencode/AGENTS.md` 等 system prompt 材料)。

規則:

- repo documented standard 永遠蓋過 smell baseline(如 repo 明確接受某 smell,suppress)
- 每個 smell 是 heuristic(labelled),MUST NOT 當 hard violation
- 略過 tooling 已強制的東西(如 linter 已檢查的格式)

`openspec-apply-change` 引用 Standards axis CRITICAL severity 時 MUST 使用相同語言("violates a documented repo standard / major Fowler smell"),兩個 skill 不得使用不同字眼指稱同一軸。

#### Scenario: repo 標準覆蓋 smell baseline

- **WHEN** Standards sub-agent 發現一個 diff hunk 觸發「Primitive Obsession」smell,但 repo 的 CODING_STANDARDS.md 明確接受該 pattern
- **THEN** sub-agent MUST suppress 該 finding(不列入報告)

#### Scenario: Fowler baseline 在無 repo 文件時仍作用

- **WHEN** repo 沒有 CODING_STANDARDS.md 也沒有 CONTRIBUTING.md
- **THEN** Standards sub-agent MUST 仍以 Fowler 12 baseline 檢查(唯一來源),MUST NOT 回退到全域指示檔

#### Scenario: severity 用語跨文件對齊

- **WHEN** 讀取 `openspec-apply-change/SKILL.md` 的 Standards axis CRITICAL 定義
- **THEN** 表述 MUST 為 "violates a documented repo standard / major Fowler smell",與 `openspec-code-review` 的來源語言一致
