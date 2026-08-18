# Delta Spec: skill-authoring-governance

## ADDED Requirements

### Requirement: writing-for-agents 以 model-invoked description 治理文件寫作

Agent 消費文件（skills、`AGENTS.md` / `CLAUDE.md`、pointer 指向的 doc）的寫作治理 SHALL 由 `writing-for-agents` skill 的 model-invoked description 承擔：`claude/skills/writing-for-agents/SKILL.md` frontmatter MUST NOT 含 `disable-model-invocation: true`，且其 description MUST 涵蓋「creating or editing skills」與「modifying AGENTS.md or CLAUDE.md」trigger branches，使 agent 在編輯 skill 或 CLAUDE.md 時能自主觸發載入規範。

#### Scenario: frontmatter 為 model-invoked
- **WHEN** 檢查 `claude/skills/writing-for-agents/SKILL.md` 的 YAML frontmatter
- **THEN** 必須沒有 `disable-model-invocation: true`，且 `description` 含 `skills` 與 `CLAUDE.md` 觸發字樣

#### Scenario: 編輯 CLAUDE.md 也能觸發規範
- **WHEN** session 中要求修改 `claude/CLAUDE.md` 內容
- **THEN** `writing-for-agents` 的 description trigger 涵蓋此 branch（不同於舊機制只蓋 skill 修改）

### Requirement: CLAUDE.md 不含重複的 skill 載入指令

`claude/CLAUDE.md` MUST NOT 包含要求「修改 skill 前先載入特定 writing skill」的規則（原「Skills 維護規範」一節）。invocation 職責由 model-invoked description 單一承擔，避免同一 trigger 的 duplication（兩份 context load、維護兩處）。

#### Scenario: CLAUDE.md 不含舊規則
- **WHEN** 檢視 `claude/CLAUDE.md`
- **THEN** 不存在「Skills 維護規範」一節，也不含 `writing-great-skills` 或「必須先載入」skill 規則字樣

## REMOVED Requirements

### Requirement: 修改 agent skill 前必須載入 writing-great-skills

**Reason**: upstream `mattpocock/skills` 已將 `writing-great-skills` 改寫為 `writing-for-agents` 並轉為 model-invoked；「CLAUDE.md 規則要求必載」的 user-invoked 混合機制由 description 自主觸發取代，且舊規則蓋不到 CLAUDE.md / AGENTS.md 編輯 branch。
**Migration**: 觸發職貵移轉至 `writing-for-agents` 的 model-invoked description（見 ADDED requirement「writing-for-agents 以 model-invoked description 治理文件寫作」）；`claude/CLAUDE.md` 的「Skills 維護規範」一節刪除。
