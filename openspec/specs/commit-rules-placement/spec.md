# commit-rules-placement

Git commit 規範的放置位置：全域 `opencode/AGENTS.md` 不承載 Git 專屬規則，commit 規則由 `/commit` skill 自包含。

## Purpose

定義 Git 規範的正確承載位置，避免 branch-specific 規則汙染全域指示檔。`/commit` skill 自包含 Conventional Commits 與互動確認流程，且不添加 AI 署名。
## Requirements
### Requirement: /commit skill 自包含且不添加 AI 署名
`opencode/commands/commit.md` SHALL 自包含 Git 規則，不引用全域指示檔作為規則來源；commit message 範例與流程 SHALL NOT 添加 `Co-Authored-By` 或任何 AI 署名 trailer。

#### Scenario: 檢查 commit.md 內容
- **WHEN** 檢視 `opencode/commands/commit.md` 全文
- **THEN** 不含 `Co-Authored-By` 字串，且無「遵循 CLAUDE.md」類 pointer

#### Scenario: /commit 流程產生 commit message
- **WHEN** 使用者透過 `/commit` 完成 Phase 4
- **THEN** commit message 不含任何 AI 署名 trailer

### Requirement: AGENTS.md 不包含 Git 規範段落
全域指示檔 `opencode/AGENTS.md`（部署為 `~/.config/opencode/AGENTS.md`）SHALL NOT 包含 Git 專屬規則（commit message 語言與格式、署名限制、commit 前確認）。此類 branch-specific 規則由 `/commit` command（`opencode/commands/commit.md`）承載。

#### Scenario: 檢查 AGENTS.md 內容
- **WHEN** 檢視 `opencode/AGENTS.md` 全文
- **THEN** 不存在「Git 規範」heading，且無 Conventional Commits、署名、commit 確認相關規則行

#### Scenario: Git 規則仍可被觸達
- **WHEN** 使用者執行 `/commit`
- **THEN** commit 規範（Conventional Commits、互動確認）由 `opencode/commands/commit.md` 提供，行為不因指示檔不含 Git 規則而改變

