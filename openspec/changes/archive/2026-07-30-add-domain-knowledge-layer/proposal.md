## Why

目前的工作流（explore → grill-me → propose → apply）中，`grill-me` 的拷問成果只留在對話裡，session 結束即蒸發。沒有一個 cross-change 的領域知識層讓未來 session 接住之前釐清過的術語與決策——每次開新 session，AI 對專案的領域理解歸零。

需要建立一個獨立於 openspec 的領域知識層：生產端靠 `grill-with-docs`（grilling + domain-modeling 的組合入口）在 grill 時同步寫入 `CONTEXT.md`；消費端靠全域 `CLAUDE.md` 規則讓每個 session 開工前讀取並使用其中的詞彙。

## What Changes

- 新增 `grill-with-docs` skill（user-invoked）：執行 `/grilling` session 並明確載入 `/domain-modeling`，確保 grill 過程中釐清的術語與決策即時落地到 `CONTEXT.md` 與 ADR
- 修改全域 `CLAUDE.md`（`dotfiles/claude/CLAUDE.md`）：新增領域知識消費規則，指示 AI 在開工前讀取 repo 根目錄的 `CONTEXT.md`，並在輸出中使用其詞彙
- `domain-modeling` 維持 model-invoked 不動：保留平時對話中及時捕捉術語的能力

## Capabilities

### New Capabilities
- `domain-knowledge-layer`: 規範全域 `CLAUDE.md` 的 CONTEXT.md 消費規則——AI 在任何 session 開工前讀取 repo 的 `CONTEXT.md`，輸出使用其詞彙，檔案不存在則靜默繼續

### Modified Capabilities
- `mattpocock-skills`: 從 4 個 vendor skill 擴充為 5 個，新增 `grill-with-docs`（user-invoked），並更新 user-invoked / model-invoked 分類清單

## Impact

- 新增 `dotfiles/claude/skills/grill-with-docs/SKILL.md` 與 `dotfiles/claude/skills/grill-with-docs/agents/openai.yaml`
- 修改 `dotfiles/claude/CLAUDE.md`（透過 `claude-config-symlink` 即時部署到 `~/.claude/CLAUDE.md`）
- 透過既有 symlink 機制，新 skill 與 CLAUDE.md 變更在下一個 session 自動生效，不需額外安裝步驟
