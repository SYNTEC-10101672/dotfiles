# openspec-skill-command-parity Delta Spec

## MODIFIED Requirements

### Requirement: 未使用的 opsx workflows SHALL 不存在於 repo

只保留實際使用的 workflow 檔案：4 個核心 commands（`explore` / `propose` / `apply` / `archive`）+ 8 個 skills（4 核心 + `openspec-tdd-verify` / `openspec-code-review` / `openspec-sync-specs` / `openspec-artifact-review`）。`new` / `continue` / `ff` / `onboard` / `sync` / `verify` / `tdd-verify` / `re-verify` / `bulk-archive` commands 與 `openspec-new-change` / `openspec-continue-change` / `openspec-ff-change` / `openspec-onboard` / `openspec-verify-change` / `openspec-bulk-archive-change` skills SHALL 不存在於 `claude/` 目錄。

#### Scenario: 目錄內容符合保留清單

- **WHEN** 列出 `claude/commands/opsx/`
- **THEN** 只含 `explore.md`、`propose.md`、`apply.md`、`archive.md`

#### Scenario: Skills 目錄符合保留清單

- **WHEN** 列出 `claude/skills/` 中 `openspec-` 開頭目錄
- **THEN** 只含 `openspec-explore`、`openspec-propose`、`openspec-apply-change`、`openspec-archive-change`、`openspec-tdd-verify`、`openspec-code-review`、`openspec-sync-specs`、`openspec-artifact-review`
