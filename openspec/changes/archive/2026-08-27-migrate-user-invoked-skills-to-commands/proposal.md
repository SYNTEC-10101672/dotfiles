# Proposal: migrate-user-invoked-skills-to-commands

## Why

5 個 user-invoked skills（`writing-fragments` / `writing-beats` / `writing-shape` / `grill-me` / `grill-with-docs`，皆 vendor 自 `mattpocock/skills`）以 `disable-model-invocation: true` 標記 user-only 觸發語意，但 OpenCode 忽略此 flag 且 skills 不在 slash command 選單 — 結果在 OpenCode 語意反轉為「只有 model 能觸發、使用者不能」。Slash command 機制在兩個工具（Claude Code、OpenCode）都原生支援使用者觸發，且提供 `$ARGUMENTS` 參數傳遞（skill 版做不到）。

## What Changes

- 新增 5 個 slash commands 於 `claude/commands/`：`writing-fragments.md`、`writing-beats.md`、`writing-shape.md`、`grill-me.md`、`grill-with-docs.md`
- 刪除 `claude/skills/` 下對應的 5 個 skill 目錄（含 `agents/openai.yaml`）
- writing 系列（full content）搬遷：frontmatter 換為 command 格式（`description` + `argument-hint`）、body 前加 `$ARGUMENTS` 行、其餘內容照搬
- grill 系列（thin wrapper，各 1 句）搬遷：同 frontmatter 轉換 + `Topic to grill: $ARGUMENTS` 行
- 同步更新 `openspec/specs/writing-skills/spec.md` 與 `openspec/specs/mattpocock-skills/spec.md`（vendor byte-level 一致的要求不再適用於這 5 個）

不移動：`grilling`、`writing-for-agents`、`domain-modeling`（model-invoked，skill 語意正確）。不修改 Makefile 與 symlink 部署鏈（`claude/commands` 已透過 `claude-config-symlink` / `opencode-commands-symlink` 部署到兩工具）。

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `writing-skills`: 檔案位置從 `claude/skills/writing-*/` 改為 `claude/commands/writing-*.md`；「與 upstream byte-level 一致」與「user-invoked 由 `disable-model-invocation: true` 保證」改為「command 格式 + 允許記錄在案的偏離（frontmatter、`$ARGUMENTS` 行）」
- `mattpocock-skills`: 規範範圍從 5 個 skills 縮為 3 個（`grilling` / `writing-for-agents` / `domain-modeling`）；`grill-me` / `grill-with-docs` 移除、由 `claude/commands/` 的 slash commands 取代；user-invoked 分類 requirement 隨之刪除

## Impact

- **Claude Code**：`/writing-fragments` 等 5 個 slash commands 出現於選單；`~/.claude/skills/` 少 5 個目錄
- **OpenCode**：`~/.config/opencode/commands/`（symlink 自 `claude/commands`）多 5 個 commands；但 `grill-me` / `grill-with-docs` 內容指向 `/grilling` / `/domain-modeling` skills — 在 `oh-my-openagent.json` 的 `claude_code.skills: false` 開啟前，這兩個 commands 在 OpenCode 無法完整執行（writing 系列自包含，不受影響）
- **Vendoring**：這 5 個檔案脫離 upstream vendor 同步流程，日後更新需手動比對 `mattpocock/skills` upstream
- **不影響**：Makefile、`make check`、其他 12 個 skills、既有 4 個 opsx commands
