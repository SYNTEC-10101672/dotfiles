# Delta Spec: commit-rules-placement

## ADDED Requirements

### Requirement: AGENTS.md 不包含 Git 規範段落
全域指示檔 `opencode/AGENTS.md`（部署為 `~/.config/opencode/AGENTS.md`）SHALL NOT 包含 Git 專屬規則（commit message 語言與格式、署名限制、commit 前確認）。此類 branch-specific 規則由 `/commit` command（`opencode/commands/commit.md`）承載。

#### Scenario: 檢查 AGENTS.md 內容
- **WHEN** 檢視 `opencode/AGENTS.md` 全文
- **THEN** 不存在「Git 規範」heading，且無 Conventional Commits、署名、commit 確認相關規則行

#### Scenario: Git 規則仍可被觸達
- **WHEN** 使用者執行 `/commit`
- **THEN** commit 規範（Conventional Commits、互動確認）由 `opencode/commands/commit.md` 提供，行為不因指示檔不含 Git 規則而改變

## MODIFIED Requirements

### Requirement: /commit skill 自包含且不添加 AI 署名
`opencode/commands/commit.md` SHALL 自包含 Git 規則，不引用全域指示檔作為規則來源；commit message 範例與流程 SHALL NOT 添加 `Co-Authored-By` 或任何 AI 署名 trailer。

#### Scenario: 檢查 commit.md 內容
- **WHEN** 檢視 `opencode/commands/commit.md` 全文
- **THEN** 不含 `Co-Authored-By` 字串，且無「遵循 CLAUDE.md」類 pointer

#### Scenario: /commit 流程產生 commit message
- **WHEN** 使用者透過 `/commit` 完成 Phase 4
- **THEN** commit message 不含任何 AI 署名 trailer

## REMOVED Requirements

### Requirement: CLAUDE.md 不包含 Git 規範段落

**Reason**: `claude/CLAUDE.md` 已搬遷改名為 `opencode/AGENTS.md`；requirement 名稱與路徑一併更新。

**Migration**: 由 ADDED requirement「AGENTS.md 不包含 Git 規範段落」承接，行為要求不變（「與 `claude/settings.json` 承載」字眼移除，規則唯一承載者為 `/commit` command）。

### Requirement: attribution 由 settings.json 機械控制

**Reason**: `claude/settings.json` 隨 claude CLI 退役刪除；opencode 端無對應機械控制設定（opencode 預設不添加 AI 署名）。

**Migration**: 「不添加 AI 署名」規則由既有 requirement「/commit skill 自包含且不添加 AI 署名」（`opencode/commands/commit.md` 自包含）承載，無需機械控制點。
