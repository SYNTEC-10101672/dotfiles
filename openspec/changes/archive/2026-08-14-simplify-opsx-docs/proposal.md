## Why

opsx workflow 檔案（`claude/commands/opsx/` + `claude/skills/openspec-*`）存在大規模內容重複：11 個 commands 是對應 skills 的近乎逐字複本（~4200 行中約一半是 duplicate），且 13 個 skill descriptions 每個 session 都佔 system prompt。使用者實際工作流程只走 4 個 slash commands（`/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:archive`），其餘 9 個 commands 與 6 個對應 skills 是死代碼。維護成本已經顯現：`propose.md` 與 skill 版措辭開始漂移，每次更新需同步兩處。

## What Changes

- **BREAKING**（對 slash command 集合）：刪除 9 個未使用的 commands：`new.md`、`continue.md`、`ff.md`、`onboard.md`、`sync.md`、`verify.md`、`tdd-verify.md`、`re-verify.md`、`bulk-archive.md`
- **BREAKING**：刪除 6 個對應的死 skills：`openspec-new-change`、`openspec-continue-change`、`openspec-ff-change`、`openspec-onboard`、`openspec-verify-change`、`openspec-bulk-archive-change`
- 將 4 個核心 commands（`explore.md`、`propose.md`、`apply.md`、`archive.md`）從全文複本（150–293 行）改為 thin wrapper（~12 行）：保留 frontmatter + input 說明 + 「Use the `openspec-<name>` skill」指向，仿 `tdd-verify.md` 既有 wrapper pattern
- Skills 成為單一真相來源（single source of truth），保留 7 個：4 個核心 + 3 個 helper（`openspec-tdd-verify`、`openspec-code-review`、`openspec-sync-specs`）
- 修正 `openspec-apply-change/SKILL.md:48` 對已刪 `openspec-continue-change` 的 dangling reference（blocked state 指引改為建議補齊 artifacts 的方式）
- 重寫 `openspec-skill-command-parity` spec：parity 模型（雙檔等價）改為 wrapper 模型（skill 單一真相 + command thin wrapper）

不變：`commands/commit.md`、`handover.md`、`eli5.md`（非 opsx）；grilling / domain-modeling / tutoring 等 non-opsx skills；`~/.claude` symlink 結構；openspec CLI 本身。

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `openspec-skill-command-parity`：核心模型反轉 — 原 spec 要求成對檔案維持 body content parity（雙檔等價、drift audit、template 對稱）；改為要求 command 是指向 skill 的 thin wrapper（frontmatter + input 說明 + skill 指向，不含 workflow 全文），skill 為單一真相來源。原 parity / drift / template 對稱 requirements 移除，新增 wrapper 結構與 skill 指向的 requirements。

## Impact

- **檔案**：`claude/commands/opsx/`（13 → 4 檔，wrapper 化）、`claude/skills/openspec-*`（13 → 7 目錄）
- **行數**：~4200 行 → ~1100 行（約 -74%）
- **System prompt**：skill descriptions 從 13 個降至 7 個（每個 session 持續節省）
- **下游引用**：`openspec-apply-change/SKILL.md:48` dangling reference 需修正；`openspec-propose/SKILL.md` 提及 `/opsx:apply`（保留，無影響）；`openspec-archive-change/SKILL.md` 提及 `openspec-sync-specs`（保留，無影響）
- **工具相容性**：wrapper pattern 已由 `tdd-verify.md` 驗證可同時在 Claude Code 與 opencode（共用 symlink）運作
- **歷史 archive changes**：`openspec/changes/archive/` 內提及已刪 commands 的文件為歷史紀錄，不修改
