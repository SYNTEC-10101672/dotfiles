## Purpose

規範 opsx workflow 的檔案歸屬：`opencode/commands/opsx/` 的 command 檔案為 workflow 內容本體（單一真相來源，經 slash command 啟動時直接送達）；`opencode/skills/` 內 `openspec-*` 前綴目錄僅存 helper 角色（被流程以 skill tool / `load_skills` 引用，不得是無 command 對應的孤兒 entry）。並約束保留集合（4 commands + 3 helper skills）與 cross-reference 的完整性——不得重建「thin wrapper + entry skill」雙層結構。
## Requirements
### Requirement: Body prose SHALL 用英文；literal format token SHALL 用英文 format identifier

Skill 檔案與 command 檔案的所有 body prose（描述、指示、解釋）SHALL 用英文撰寫。屬於 OpenSpec task-format 合約的 literal token — 特別是 section ID `## Tests` 與 `## Implementation`、field label `> Command:` 與 `> Expected:`、cross-reference marker `(→ T<n>)` — SHALL 使用英文，因為它們是 `openspec/specs/openspec-tdd-task-format/` 定義的 format identifier，英文 token 利於 model reliably match。

這個 requirement 確保 format identifier 與 body prose 統一用英文，同時 artifact content（tasks.md / design.md / proposal 的 prose）維持繁體中文撰寫。

#### Scenario: Format identifier 使用英文
- **WHEN** skill 或 command 檔案描述 tasks.md 格式
- **THEN** 描述用英文撰寫，literal token `## Tests`、`## Implementation`、`> Command:`、`> Expected:`、`(→ T<n>)` 在 code span 或 code block 中使用英文

#### Scenario: 中文 instruction body 改寫成英文
- **WHEN** 既有 body 段落含中文描述（例如 skill 步驟用中文撰寫）
- **THEN** 該段落 SHALL 改寫成英文，token 使用上述英文 format identifier

### Requirement: 核心 opsx commands SHALL 為內容自足的 workflow 本體

`opencode/commands/opsx/` 內每個 command 檔案 SHALL 自足承載完整 workflow 內容：frontmatter（`name`、`description`、`category`、`tags`）、用途說明、`**Input**` 段落、workflow 步驟、format spec、範例、output template、guardrails。Command 檔案 SHALL NOT 含有「Use the `openspec-<name>` skill」形式的 skill 指向行——流程經 slash command 啟動時內容直接送達，不經 skill tool 轉載。

#### Scenario: Command 檔案含完整 workflow 內容

- **WHEN** 檢視 `opencode/commands/opsx/apply.md`
- **THEN** 檔案含 TDD 三階段步驟與 output template，且不含 skill 指向行

#### Scenario: 流程步驟引用 helper skills

- **WHEN** command 內文的流程步驟需要 `openspec-tdd-verify` 等能力
- **THEN** 以「invoke the `openspec-<helper>` skill」字句引用，主 agent 以 skill tool 載入，sub-agent 經 `load_skills` 注入

### Requirement: Command 檔案 SHALL 為 workflow 內容的單一真相來源

每個 opsx workflow 的完整內容 SHALL 只存在於對應 `opencode/commands/opsx/<name>.md` 一處。任何 workflow 內容更新 SHALL 只修改 command 檔案。`opencode/commands/opsx/` 與 `opencode/skills/` 之間 SHALL NOT 重建「thin wrapper + entry skill」雙層結構。

#### Scenario: Workflow 更新只改一份

- **WHEN** 維護者調整 archive flow 的 confirmation 步驟
- **THEN** 只修改 `opencode/commands/opsx/archive.md`，無其他檔案承載同一 workflow 的內容

### Requirement: openspec-* skills SHALL 僅為被流程引用的 helper

`opencode/skills/` 內 `openspec-` 前綴目錄 SHALL 僅存 helper 角色：被至少一個 opsx workflow command 或 agent 流程以 skill tool / `load_skills` 引用。無 command 對應、未被任何流程引用的孤兒 entry skill（如 workflow 本體的 skill 版本）SHALL NOT 存在。

非 `openspec-` 前綴的 vendor skill（如 mattpocock 系列 `code-review`）不屬 helper 保留清單管轄，其存在與內容由 `mattpocock-skills` capability 規範。

#### Scenario: Skills 目錄只含 helpers

- **WHEN** 列出 `opencode/skills/` 中 `openspec-` 開頭目錄
- **THEN** 只含 `openspec-tdd-verify`、`openspec-artifact-review`、`openspec-sync-specs`

### Requirement: 保留的 opsx 檔案 SHALL 無 dangling cross-references

保留的 command 檔案與 helper skill 檔案內所有 cross-reference（skill 名、slash command 名、流程名）SHALL 指向存在的檔案或流程。entry skill 名識別字——`openspec-explore`、`openspec-propose`、`openspec-apply-change`、`openspec-archive-change`、以及 bare `openspec-apply`——SHALL NOT 出現於 `opencode/` 內任何檔案；流程引用一律使用 slash form（`/opsx:explore`、`/opsx:propose`、`/opsx:apply`、`/opsx:archive`）。`opsx:apply` 對 code review 能力的引用 SHALL 使用 skill 名 `code-review`（非 `openspec-code-review`）。

#### Scenario: Helper skill description 引用 slash form

- **WHEN** 檢視 `opencode/skills/openspec-artifact-review/SKILL.md` 的 frontmatter description
- **THEN** 流程引用為 `/opsx:propose` 與 `/opsx:apply`，非舊 skill 名識別字

#### Scenario: Apply command 引用存在的 code review skill

- **WHEN** 檢視 `opencode/commands/opsx/apply.md` 的 code review invocation
- **THEN** 引用對象為 `code-review`，且 `opencode/skills/code-review/SKILL.md` 存在

#### Scenario: Apply command 不引用已刪 skill

- **WHEN** 檢視 `opencode/commands/opsx/apply.md` 的 blocked-state 指引
- **THEN** 該指引不含 `openspec-continue-change` 或任何 entry skill 名字樣，且提供替代建議（如建立缺少的 artifact）

### Requirement: 未使用的 opsx workflows SHALL 不存在於 repo

只保留實際使用的 workflow 檔案：4 個核心 commands（`explore.md` / `propose.md` / `apply.md` / `archive.md`，各為內容自足的 workflow 本體）+ 3 個 helper skills（`openspec-tdd-verify` / `openspec-artifact-review` / `openspec-sync-specs`）。`openspec-explore` / `openspec-propose` / `openspec-apply-change` / `openspec-archive-change` / `openspec-code-review` skill 目錄 SHALL 不存在於 `opencode/skills/`。code review 能力由 vendor skill `code-review` 提供（見 `mattpocock-skills` 與 `code-review` capabilities）。

#### Scenario: 目錄內容符合保留清單

- **WHEN** 列出 `opencode/commands/opsx/`
- **THEN** 只含 `explore.md`、`propose.md`、`apply.md`、`archive.md`

#### Scenario: Skills 目錄符合保留清單

- **WHEN** 列出 `opencode/skills/` 中 `openspec-` 開頭目錄
- **THEN** 只含 `openspec-tdd-verify`、`openspec-artifact-review`、`openspec-sync-specs`
