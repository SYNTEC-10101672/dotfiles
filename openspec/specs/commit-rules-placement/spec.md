# commit-rules-placement

Git commit 規範的放置位置：全域 `claude/CLAUDE.md` 不承載 Git 專屬規則，commit 規則由 `/commit` skill 自包含，AI attribution 由 `claude/settings.json` 機械控制。

## Purpose

定義 Git 規範的正確承載位置，避免 branch-specific 規則汙染全域 CLAUDE.md。`/commit` skill 自包含 Conventional Commits 與互動確認流程，`claude/settings.json` 負責隱藏 AI attribution。

## Requirements

### Requirement: CLAUDE.md 不包含 Git 規範段落
全域 `claude/CLAUDE.md` SHALL NOT 包含 Git 專屬規則（commit message 語言與格式、署名限制、commit 前確認）。此類 branch-specific 規則由 `/commit` skill 與 `claude/settings.json` 承載。

#### Scenario: 檢查 CLAUDE.md 內容
- **WHEN** 檢視 `claude/CLAUDE.md` 全文
- **THEN** 不存在「Git 規範」heading，且無 Conventional Commits、署名、commit 確認相關規則行

#### Scenario: Git 規則仍可被觸達
- **WHEN** 使用者執行 `/commit`
- **THEN** commit 規範（Conventional Commits、互動確認）由 `claude/commands/commit.md` 提供，行為不因 CLAUDE.md 移除而改變

### Requirement: attribution 由 settings.json 機械控制
`claude/settings.json` SHALL 設定 `"attribution": { "commit": "", "pr": "" }`，隱藏 git commit 與 PR description 的 AI attribution。SHALL NOT 使用已 DEPRECATED 的 `includeCoAuthoredBy`。

#### Scenario: settings.json 設定存在
- **WHEN** 檢視 `claude/settings.json`
- **THEN** 包含 `"attribution"` 物件，`commit` 與 `pr` 皆為空字串，且不含 `includeCoAuthoredBy`

#### Scenario: Claude Code 產生 commit
- **WHEN** Claude Code（支援 attribution key 的版本）執行 git commit
- **THEN** commit message 不含 `Co-Authored-By: Claude` trailer

### Requirement: /commit skill 自包含且不添加 AI 署名
`claude/commands/commit.md` SHALL 自包含 Git 規則，不引用 CLAUDE.md 作為規則來源；commit message 範例與流程 SHALL NOT 添加 `Co-Authored-By` 或任何 AI 署名 trailer。

#### Scenario: 檢查 commit.md 內容
- **WHEN** 檢視 `claude/commands/commit.md` 全文
- **THEN** 不含 `Co-Authored-By` 字串，且無「遵循 CLAUDE.md」類 pointer

#### Scenario: /commit 流程產生 commit message
- **WHEN** 使用者透過 `/commit` 完成 Phase 4
- **THEN** commit message 不含任何 AI 署名 trailer
