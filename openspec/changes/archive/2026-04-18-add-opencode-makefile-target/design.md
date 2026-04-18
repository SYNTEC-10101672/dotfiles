## Context

dotfiles 專案透過 Makefile target 管理各設定模組（bash、nvim、claude、git、tig、tmux、scripts），每個 target 在 `$HOME` 建立 symlink 指向 repo 內的檔案。OpenCode 是一個 CLI coding agent，對 Claude Code 設定有內建相容性：CLAUDE.md 和 skills 自動 fallback，但 commands 讀取 `~/.config/opencode/commands/`，需要手動建立 symlink。

目前 `claude/commands/` 內的 commands 主要是 workflow 描述，Claude Code-specific tools（如 AskUserQuestion）在 OpenCode 中頂多被忽略，不會崩潰。

## Goals / Non-Goals

**Goals:**
- 新增 `opencode` Makefile target，建立 `~/.config/opencode/commands` → `dotfiles/claude/commands` symlink
- 整合到現有 `install`、`uninstall`、`check`、`help` 流程中
- 風格與現有 target 一致

**Non-Goals:**
- 不處理 OpenCode 其他設定（CLAUDE.md、skills 已自動相容）
- 不為 OpenCode 建立獨立的 commands 目錄
- 不修改 commands 內容以適配 OpenCode

## Decisions

1. **直接 symlink 而非複製**
   - 選擇 symlink `~/.config/opencode/commands` → `dotfiles/claude/commands`
   - 替代方案：分開維護兩份 commands（維護成本高）、使用 script 動態產生（不必要）
   - 理由：commands 內容完全共用，symlink 維護成本最低

2. **使用 `ln -sfn`**
   - 與 `nvim` target（同為目錄 symlink）一致
   - `-n` 避免 symlink 指向 symlink 內部的問題

3. **放在 `claude` target 之後、`git` 之前**
   - 邏輯上 opencode commands 依賴 claude commands，排在 claude 之後合理

## Risks / Trade-offs

- **OpenCode commands 格式差異** → Claude Code-specific frontmatter（如 `allowedTools`）在 OpenCode 中可能被忽略，但不會造成錯誤。未來如有需要可考慮分開維護，目前風險極低。
