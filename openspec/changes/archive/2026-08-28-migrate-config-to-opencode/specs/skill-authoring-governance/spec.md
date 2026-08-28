# Delta Spec: skill-authoring-governance

## ADDED Requirements

### Requirement: writing-for-agents 以 model-invoked description 治理 skills 與指示檔寫作

Agent 消費文件（skills、`AGENTS.md`、pointer 指向的 doc）的寫作治理 SHALL 由 `writing-for-agents` skill 的 model-invoked description 承擔：`opencode/skills/writing-for-agents/SKILL.md` frontmatter MUST NOT 含 `disable-model-invocation: true`，且其 description MUST 涵蓋「creating or editing skills」與「modifying AGENTS.md or CLAUDE.md」trigger branches，使 agent 在編輯 skill 或指示檔時能自主觸發載入規範。

#### Scenario: frontmatter 為 model-invoked
- **WHEN** 檢查 `opencode/skills/writing-for-agents/SKILL.md` 的 YAML frontmatter
- **THEN** 必須沒有 `disable-model-invocation: true`，且 `description` 含 `skills` 與 `CLAUDE.md` 觸發字樣

#### Scenario: 編輯全域指示檔也能觸發規範
- **WHEN** session 中要求修改 `opencode/AGENTS.md` 內容
- **THEN** `writing-for-agents` 的 description trigger 涵蓋此 branch（不同於舊機制只蓋 skill 修改）

### Requirement: AGENTS.md 不含重複的 skill 載入指令

`opencode/AGENTS.md` MUST NOT 包含要求「修改 skill 前先載入特定 writing skill」的規則（原「Skills 維護規範」一節）。invocation 職責由 model-invoked description 單一承擔，避免同一 trigger 的 duplication（兩份 context load、維護兩處）。

#### Scenario: AGENTS.md 不含舊規則
- **WHEN** 檢視 `opencode/AGENTS.md`
- **THEN** 不存在「Skills 維護規範」一節，也不含任何「必須先載入」特定 writing skill 的規則字樣

### Requirement: explore mode 寫檔白名單

`opencode/skills/openspec-explore/SKILL.md` SHALL 以白名單制規範 explore mode 的檔案寫入：僅允許寫入 OpenSpec artifacts（`openspec/changes/**`）與經 domain-modeling 程序 resolved 的 `CONTEXT.md`。Skill 檔案 SHALL NOT 含有「"capturing thinking" 類比的模糊例外」或「未經程序即寫入 `CONTEXT.md`（如 right away）」的指示；此類指示與 "Don't auto-capture" guardrail 的矛盾 SHALL 被消除。

#### Scenario: 白名單文字存在

- **WHEN** 檢視 `opencode/skills/openspec-explore/SKILL.md` 的寫檔規範段落（開頭 IMPORTANT 段與 Guardrails 段）
- **THEN** 該段落明列允許寫入的路徑（`openspec/changes/**` 與 `CONTEXT.md`），且不含 "that's capturing thinking, not implementing" 類比句與 "right away" 寫入指示

#### Scenario: 引導實作請求至 propose

- **WHEN** explore mode 中使用者要求直接修改 code（如「那你直接改一改」）
- **THEN** skill 指示 AI 拒絕寫入並引導使用者執行 `/opsx:propose`，且此行為以對話範例（few-shot）形式呈現於 skill 的 entry-point 範例區

### Requirement: CONTEXT.md 寫入須走 domain-modeling 程序

`opencode/skills/openspec-explore/SKILL.md` 與 `opencode/skills/openspec-propose/SKILL.md` 中所有涉及 `CONTEXT.md` 寫入的指示 SHALL 遵循一致程序：詞彙 crystallize 時 invoke `domain-modeling` skill（或至少先讀同 skills 目錄下 `domain-modeling` 的 `SKILL.md` 與 `CONTEXT-FORMAT.md`），經挑戰程序 resolved 後才寫入。兩個 skill SHALL NOT 含有 "right away"、"immediately"、"Do not batch" 等繞過程序的寫入指示。

#### Scenario: explore skill 程序指示

- **WHEN** 檢視 `opencode/skills/openspec-explore/SKILL.md` 的 domain vocabulary 條目
- **THEN** 指示要求 invoke `domain-modeling` skill 走挑戰程序（challenge → resolve → write），而非直接寫入

#### Scenario: propose skill 程序指示

- **WHEN** 檢視 `opencode/skills/openspec-propose/SKILL.md` 的 domain vocabulary 條目
- **THEN** "immediately / right away / Do not batch" 字眼已移除，指示與 explore skill 的程序一致

#### Scenario: grep 驗證舊字眼消除

- **WHEN** 在 `opencode/skills/openspec-explore/SKILL.md` 與 `opencode/skills/openspec-propose/SKILL.md` 內 grep `right away`、`immediately`、`Do not batch`
- **THEN** 兩檔案的 `CONTEXT.md` 寫入指示段落無這些字眼（非 CONTEXT.md 語境的其他用法不在此限）

## REMOVED Requirements

### Requirement: writing-for-agents 以 model-invoked description 治理文件寫作

**Reason**: 路徑由 `claude/skills/` 改寫為 `opencode/skills/`、宿主指示檔由 `claude/CLAUDE.md` 改為 `opencode/AGENTS.md`，scenario 名稱含舊檔名（「編輯 CLAUDE.md 也能觸發規範」），MODIFIED 無法表達 scenario 改名。

**Migration**: 由 ADDED requirement「writing-for-agents 以 model-invoked description 治理 skills 與指示檔寫作」承接，規範內容不變、路徑全面更新。

### Requirement: CLAUDE.md 不含重複的 skill 載入指令

**Reason**: `claude/CLAUDE.md` 已搬遷改名為 `opencode/AGENTS.md`。

**Migration**: 由 ADDED requirement「AGENTS.md 不含重複的 skill 載入指令」承接，行為要求不變。
