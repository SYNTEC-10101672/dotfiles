## Why

目前 `dotfiles/.claude/` 同時承載兩種用途：Claude Code 全域 user settings（CLAUDE.md、settings.json、commands、skills、scripts）以及 repo 內的設定檔。這導致無法為 dotfiles 專案本身建立 project-level 的 `CLAUDE.md`（Claude Code 專用），也讓目錄意圖不夠清晰。

此外，Makefile 中的 backup/restore/clean 功能幾乎不使用，且 `make restore` 的 `cp -r` 行為有覆蓋 Claude Code runtime data 的風險。

## What Changes

- 將 `dotfiles/.claude/` rename 為 `dotfiles/claude/`，使其成為 visible 目錄
- 新建 `dotfiles/.claude/CLAUDE.md` 作為 project-level 指令（僅限此 repo）
- 更新 Makefile：修改 claude target 的 source path、移除 backup/restore/clean 功能
- 更新 `.gitignore`：反映目錄改名，新增 `.claude/` 兜底規則
- 更新 `README.md`：反映新的專案結構

## Capabilities

### New Capabilities

- `project-claude-md`: dotfiles 專案的 project-level CLAUDE.md，描述專案結構、部署方式、和新增模組的慣例

### Modified Capabilities

- `claude-config-symlink`: source path 從 `.claude/` 改為 `claude/`，移除 backup 相關行為

## Impact

- **已部署環境**：需要移除舊 symlinks 後重新 `make claude`，Claude Code runtime data 不受影響
- **Makefile**：移除 `backup`、`restore`、`clean` 三個 target
- **其他設定檔**（scripts、commands、skills）：不受影響，引用的都是 `~/.claude/` 部署路徑
