# domain-knowledge-layer

全域 CLAUDE.md 的領域知識消費規則，讓 AI 在任何 session 開工前讀取 repo 的 `CONTEXT.md` 並使用其詞彙。獨立於 openspec 工作流，作為 cross-change 的領域知識層。

## Purpose

提供一條全域消費規則，確保 AI session 自動讀取並遵循 repo 的 `CONTEXT.md` 領域詞彙表，減少輸出的詞彙漂移。知識層獨立於 openspec 的 per-change artifacts，是 cross-change 的長期詞彙來源。

## Requirements

### Requirement: 全域 CLAUDE.md 包含 CONTEXT.md 消費規則

全域 CLAUDE.md（`dotfiles/claude/CLAUDE.md`，透過 symlink 部署為 `~/.claude/CLAUDE.md`）SHALL 包含一條領域知識消費規則，指示 AI 在探索 codebase 前讀取 repo 根目錄的 `CONTEXT.md`（若存在），並在輸出（issue 標題、test 名稱、refactor 提案、hypothesis）中使用 `CONTEXT.md` 定義的詞彙，不漂移到同義詞。若 `CONTEXT.md` 不存在，SHALL 靜默繼續，不報錯、不建議建立。

#### Scenario: CLAUDE.md 包含消費規則
- **WHEN** 檢查 `dotfiles/claude/CLAUDE.md` 內容
- **THEN** 必須包含一個獨立章節，提及 `CONTEXT.md`，且規則涵蓋「開工前讀取」「使用詞彙不漂移」「不存在則靜默繼續」三點

#### Scenario: 有 CONTEXT.md 的 repo
- **WHEN** AI 在根目錄含有 `CONTEXT.md` 的 repo 開始工作
- **THEN** AI 在探索 codebase 前讀取 `CONTEXT.md`，且輸出使用其定義的詞彙

#### Scenario: 沒有 CONTEXT.md 的 repo
- **WHEN** AI 在根目錄沒有 `CONTEXT.md` 的 repo 工作
- **THEN** AI 靜默繼續，不報錯、不建議建立 `CONTEXT.md`

#### Scenario: 多 context repo
- **WHEN** repo 根目錄含有 `CONTEXT-MAP.md`（指向多個 per-context `CONTEXT.md`）
- **THEN** AI 讀取 `CONTEXT-MAP.md` 後，讀取與當前主題相關的 per-context `CONTEXT.md`
