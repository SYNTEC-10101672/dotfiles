# Delta: openspec-skill-command-parity

## MODIFIED Requirements

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
