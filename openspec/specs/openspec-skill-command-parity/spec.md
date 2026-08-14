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

### Requirement: Structured output template SHALL 同時存在於 pair 的兩個檔案

當 pair 的一邊含 structured output template（例如 `Output On Success`、`Output On Success With Warnings`、`Output On Error`，並附 literal markdown template 顯示訊息格式），另一邊 SHALL 含相同 set 的 template 且內容等價。Subagent 走 skill path 與 user 走 slash command SHALL 看到相同的 structured error reporting。

#### Scenario: Archive output template 同時存在於兩個檔案
- **WHEN** `commands/opsx/archive.md` 定義三個 output template：`Output On Success (No Delta Specs)`、`Output On Success With Warnings`、`Output On Error (Archive Exists)`
- **THEN** `skills/openspec-archive-change/SKILL.md` SHALL 定義相同三個 template，markdown 結構等價

### Requirement: Confirmation UX SHALL 跨 pair 一致

當 pair 的一邊對 user confirmation 明確 mandate 特定工具（例如 `AskUserQuestion`），另一邊 SHALL mandate 相同工具。當另一邊已經命名具體工具時，pair 那邊用「prompt the user」或「ask for confirmation」這種 generic 用語 NOT acceptable。

#### Scenario: Archive confirmation 兩邊都用 AskUserQuestion
- **WHEN** `skills/openspec-archive-change/SKILL.md` mandate `AskUserQuestion` tool 用於 confirmation prompt
- **THEN** `commands/opsx/archive.md` SHALL 對相同 confirmation prompt mandate `AskUserQuestion` tool（取代 generic 的 "Prompt user for confirmation" 用語）

### Requirement: Cross-reference style SHALL 每個檔案內部一致

每個檔案 SHALL 全文使用單一 cross-reference style：
- `commands/opsx/<name>.md` SHALL 用 slash command 語法 reference peer（`/opsx:<peer>`、`/opsx:continue`、`/opsx:archive`）
- `skills/openspec-<name>-change/SKILL.md` SHALL 用 bare skill 名字 reference peer（`openspec-<peer>-change`、`openspec-continue-change`、`openspec-archive-change`）

單一檔案內混合 style 視為 parity 違反。

#### Scenario: Command 檔案全文用 slash command style
- **WHEN** `commands/opsx/apply.md` 在 "blocked state" 指引中提到 continue workflow
- **THEN** 該 reference 用 `/opsx:continue`（不用 `openspec-continue-change`）

#### Scenario: Skill 檔案全文用 bare 名字 style
- **WHEN** `skills/openspec-apply-change/SKILL.md` 在 "blocked state" 指引中提到 continue workflow
- **THEN** 該 reference 用 `openspec-continue-change`（不用 `/opsx:continue`）

### Requirement: Body prose SHALL 用英文；literal format token SHALL 用英文 format identifier

成對檔案的所有 body prose（描述、指示、解釋）SHALL 用英文撰寫。屬於 OpenSpec task-format 合約的 literal token — 特別是 section ID `## Tests` 與 `## Implementation`、field label `> Command:` 與 `> Expected:`、cross-reference marker `(→ T<n>)` — SHALL 使用英文，因為它們是 `openspec/specs/openspec-tdd-task-format/` 定義的 format identifier，英文 token 利於 model reliably match。

這個 requirement 確保 format identifier 與 body prose 統一用英文，同時 artifact content（tasks.md / design.md / proposal 的 prose）維持繁體中文撰寫。

#### Scenario: Format identifier 使用英文
- **WHEN** 成對檔案描述 tasks.md 格式
- **THEN** 描述用英文撰寫，literal token `## Tests`、`## Implementation`、`> Command:`、`> Expected:`、`(→ T<n>)` 在 code span 或 code block 中使用英文

#### Scenario: 中文 instruction body 改寫成英文
- **WHEN** 既有 body 段落含中文描述（例如 skill 步驟用中文撰寫）
- **THEN** 該段落 SHALL 改寫成英文，token 使用上述英文 format identifier

### Requirement: 達成 parity 時 SHALL 不改 frontmatter

Frontmatter 欄位 `name`、`description`、`category`、`tags`、`license`、`compatibility`、`metadata.*` 在兩種檔案類型中各有不同用途：
- Command frontmatter（`name: "OPSX: <Display>"`、`category`、`tags`）驅動 OpenCode 的 slash-command discovery 與 UI grouping
- Skill frontmatter（`name: openspec-<name>`、`description`、`license`、`metadata.author/version/generatedBy`）驅動 skill matching

Parity edit SHALL 不改 frontmatter。為了讓兩個檔案「match」而改 frontmatter 會破壞 auto-load 行為並混淆上游 version tracking。

#### Scenario: Parity edit 略過 frontmatter
- **WHEN** 維護者對齊 `commands/opsx/archive.md` 與 `skills/openspec-archive-change/SKILL.md` 的 body
- **THEN** 兩個檔案的 frontmatter 區塊與編輯前狀態 byte-identical

### Requirement: Parity audit 程序 SHALL 可重現

Parity audit 是具體、可重現的程序 — 不是判斷題。維護者 SHALL 能透過確定性指令執行，並套用客觀的 drift 判定標準。

#### Scenario: Audit 指令序列
- **WHEN** 維護者想 audit 所有 pair 是否 drift
- **THEN** 維護者對每組 pair `<cmd>:<skill>` 跑：`diff <(tail -n +6 claude/commands/opsx/<cmd>.md) <(tail -n +10 claude/skills/openspec-<skill>/SKILL.md)`（skip frontmatter）並檢視 output

#### Scenario: Drift 嚴重度分類 — ALIGNED
- **WHEN** 某組 pair 的 audit diff 只顯示 frontmatter 差異與 cross-reference style 差異（`/opsx:foo` ↔ `openspec-foo-change`）
- **THEN** 該 pair 分類為 `ALIGNED`，無需動作

#### Scenario: Drift 嚴重度分類 — content drift
- **WHEN** audit diff 顯示 missing section、missing format spec 或 missing structured template
- **THEN** 該 pair 分類為 `DRIFTED`，MUST 透過新的 openspec change reconcile
