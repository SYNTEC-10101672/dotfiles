# openspec-skill-command-parity Delta

## REMOVED Requirements

### Requirement: 成對的 skill/command 檔案 SHALL 維持 body content parity

**Reason**: 模型反轉 — command 不再持有 workflow 全文，改為 thin wrapper 指向 skill。雙檔等價、drift audit、10 行 delta 判定等機制隨之失效。取代於 ADDED「Thin wrapper 結構」。

### Requirement: Structured output template SHALL 同時存在於 pair 的兩個檔案

**Reason**: command 不再包含 output template；template 僅存在於 skill（單一真相來源）。取代於 ADDED「Skill 為單一真相來源」。

### Requirement: Confirmation UX SHALL 跨 pair 一致

**Reason**: 只剩一份全文（skill），無「跨檔一致」問題。

### Requirement: Cross-reference style SHALL 每個檔案內部一致

**Reason**: command wrapper 僅含一個指向（`openspec-<name>` skill），skill 內部 cross-reference 慣例由 ADDED 條文規範。

### Requirement: Parity audit 程序 SHALL 可重現

**Reason**: parity 模型移除後，pair-diff audit 程序無適用對象。新的驗證方式（wrapper 指向 + 無 dangling reference）由 ADDED 條文定義。

### Requirement: 達成 parity 時 SHALL 不改 frontmatter

**Reason**: 「parity edit」概念隨 parity 模型移除。frontmatter 的實質保護由 ADDED「Thin wrapper 結構」requirement 承接（明訂 command SHALL 含 `name`、`description`、`category`、`tags` frontmatter）。

## MODIFIED Requirements

### Requirement: Body prose SHALL 用英文；literal format token SHALL 用英文 format identifier

Skill 檔案與 command wrapper 的所有 body prose（描述、指示、解釋）SHALL 用英文撰寫。屬於 OpenSpec task-format 合約的 literal token — 特別是 section ID `## Tests` 與 `## Implementation`、field label `> Command:` 與 `> Expected:`、cross-reference marker `(→ T<n>)` — SHALL 使用英文，因為它們是 `openspec/specs/openspec-tdd-task-format/` 定義的 format identifier，英文 token 利於 model reliably match。

這個 requirement 確保 format identifier 與 body prose 統一用英文，同時 artifact content（tasks.md / design.md / proposal 的 prose）維持繁體中文撰寫。

#### Scenario: Format identifier 使用英文
- **WHEN** skill 或 wrapper 檔案描述 tasks.md 格式
- **THEN** 描述用英文撰寫，literal token `## Tests`、`## Implementation`、`> Command:`、`> Expected:`、`(→ T<n>)` 在 code span 或 code block 中使用英文

#### Scenario: 中文 instruction body 改寫成英文
- **WHEN** 既有 body 段落含中文描述（例如 skill 步驟用中文撰寫）
- **THEN** 該段落 SHALL 改寫成英文，token 使用上述英文 format identifier

## ADDED Requirements

### Requirement: 核心 opsx commands SHALL 為指向 skill 的 thin wrapper

`claude/commands/opsx/` 內每個 command 檔案 SHALL 只包含：frontmatter（`name`、`description`、`category`、`tags`）、一句用途說明、`**Input**` 段落（argument 語意）、以及明確的 skill 指向（「Use the `openspec-<name>` skill to ...」）。Workflow 步驟、format spec、範例、示意圖、output template SHALL NOT 出現在 command 檔案中 — 這些內容只存在於對應的 `claude/skills/openspec-<name>/SKILL.md`。

#### Scenario: Wrapper 檔案結構
- **WHEN** 檢視 `claude/commands/opsx/apply.md`
- **THEN** 檔案只含 frontmatter、用途說明、Input 段落、skill 指向；不含 TDD 三階段步驟或 output template

#### Scenario: Wrapper 指向存在的 skill
- **WHEN** wrapper 文字引用 skill 名（如 `openspec-apply-change`）
- **THEN** `claude/skills/openspec-apply-change/SKILL.md` 存在

### Requirement: Skill 檔案 SHALL 為 workflow 內容的單一真相來源

每個保留的 opsx workflow 的完整內容（步驟、format spec、範例、output template、guardrails）SHALL 只存在於 `claude/skills/openspec-<name>/SKILL.md` 一處。任何 workflow 內容更新 SHALL 只修改 skill 檔案。

#### Scenario: Workflow 更新只改一份
- **WHEN** 維護者調整 archive flow 的 confirmation 步驟
- **THEN** 只修改 `claude/skills/openspec-archive-change/SKILL.md`；`claude/commands/opsx/archive.md`（wrapper）不需變更

### Requirement: 未使用的 opsx workflows SHALL 不存在於 repo

只保留實際使用的 workflow 檔案：4 個核心 commands（`explore` / `propose` / `apply` / `archive`）+ 7 個 skills（4 核心 + `openspec-tdd-verify` / `openspec-code-review` / `openspec-sync-specs`）。`new` / `continue` / `ff` / `onboard` / `sync` / `verify` / `tdd-verify` / `re-verify` / `bulk-archive` commands 與 `openspec-new-change` / `openspec-continue-change` / `openspec-ff-change` / `openspec-onboard` / `openspec-verify-change` / `openspec-bulk-archive-change` skills SHALL 不存在於 `claude/` 目錄。

#### Scenario: 目錄內容符合保留清單
- **WHEN** 列出 `claude/commands/opsx/`
- **THEN** 只含 `explore.md`、`propose.md`、`apply.md`、`archive.md`

#### Scenario: Skills 目錄符合保留清單
- **WHEN** 列出 `claude/skills/` 中 `openspec-` 開頭目錄
- **THEN** 只含 `openspec-explore`、`openspec-propose`、`openspec-apply-change`、`openspec-archive-change`、`openspec-tdd-verify`、`openspec-code-review`、`openspec-sync-specs`

### Requirement: 保留的 skills SHALL 無 dangling cross-references

保留的 7 個 skill 檔案內所有 cross-reference（skill 名、slash command 名）SHALL 指向保留的檔案。特別是 `openspec-apply-change/SKILL.md` 的 blocked-state 指引 SHALL 不再引用已刪除的 `openspec-continue-change`，改為建議補齊缺少的 artifacts。

#### Scenario: apply skill 不引用 continue skill
- **WHEN** 檢視 `claude/skills/openspec-apply-change/SKILL.md` 的 blocked-state 指引
- **THEN** 該指引不包含 `openspec-continue-change` 字樣，且提供替代建議（如建立缺少的 artifact）
