## MODIFIED Requirements

### Requirement: 成對的 skill/command 檔案 SHALL 維持 body content parity

同時以 `claude/skills/openspec-<name>/SKILL.md` 與 `claude/commands/opsx/<name>.md` 兩種形式存在的每個 workflow，其 body section（workflow 步驟、format spec、範例、示意圖、entry-point 指引）SHALL 以等價的語意內容出現在兩個檔案中。兩個檔案服務不同 invocation path（subagent auto-load vs. explicit slash command），但 operational guidance MUST NOT drift — user 走 `/opsx:<name>` SHALL 拿到與 subagent load `openspec-<name>` 等價品質的指引。

Prose 用語差異可接受；missing section、missing format spec、missing structured 範例不接受。

#### Scenario: 格式說明同時存在於 pair 的兩個檔案
- **WHEN** `skills/openspec-continue-change/SKILL.md` 描述 `## Tests` / `## Implementation` 雙區塊 tasks.md 格式（含 token `> Command:`、`> Expected:`、`(→ T<n>)`）
- **THEN** `commands/opsx/continue.md` SHALL 包含一段同等描述雙區塊格式的段落，使用相同的 literal token

#### Scenario: Entry-point 範例同時存在於 pair 的兩個檔案
- **WHEN** `skills/openspec-explore/SKILL.md` 含 "Handling Different Entry Points" section，涵蓋 vague idea / specific problem / stuck mid-implementation / compare options 四種 pattern
- **THEN** `commands/opsx/explore.md` SHALL 含等價的 "Handling Different Entry Points" section，涵蓋同樣四種 entry pattern 並附等價示意圖範例

#### Scenario: Audit 偵測到 drift
- **WHEN** 維護者對 pair 執行 `diff <(cat commands/opsx/<name>.md) <(cat skills/openspec-<name>-change/SKILL.md)`（排除 frontmatter），且行數 delta（排除 frontmatter 與 cross-reference style 差異後）超過 10 行
- **THEN** 此 pair 被標為 drifted，MUST 透過新的 openspec change reconcile

### Requirement: Body prose SHALL 用英文；literal format token SHALL 用英文 format identifier

成對檔案的所有 body prose（描述、指示、解釋）SHALL 用英文撰寫。屬於 OpenSpec task-format 合約的 literal token — 特別是 section ID `## Tests` 與 `## Implementation`、field label `> Command:` 與 `> Expected:`、cross-reference marker `(→ T<n>)` — SHALL 使用英文，因為它們是 `openspec/specs/openspec-tdd-task-format/` 定義的 format identifier，英文 token 利於 model reliably match。

這個 requirement 確保 format identifier 與 body prose 統一用英文，同時 artifact content（tasks.md / design.md / proposal 的 prose）維持繁體中文撰寫。

#### Scenario: Format identifier 使用英文
- **WHEN** 成對檔案描述 tasks.md 格式
- **THEN** 描述用英文撰寫，literal token `## Tests`、`## Implementation`、`> Command:`、`> Expected:`、`(→ T<n>)` 在 code span 或 code block 中使用英文

#### Scenario: 中文 instruction body 改寫成英文
- **WHEN** 既有 body 段落含中文描述（例如 skill 步驟用中文撰寫）
- **THEN** 該段落 SHALL 改寫成英文，token 使用上述英文 format identifier
