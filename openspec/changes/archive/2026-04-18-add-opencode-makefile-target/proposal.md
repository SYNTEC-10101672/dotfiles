## Why

OpenCode 對 Claude Code 設定有內建相容性，CLAUDE.md 和 skills 已自動共用，但 commands 需要額外處理——OpenCode 讀取 `~/.config/opencode/commands/` 而非 `~/.claude/commands/`。需要一個 Makefile target 來建立 symlink，讓 commands 在兩個工具間共用。

## What Changes

- 在 Makefile 新增 `opencode` target，建立 `~/.config/opencode/commands` → `dotfiles/claude/commands` 的 symlink
- 將 `opencode` 加入 `install` 依賴和 `.PHONY`
- 在 `check` target 新增 opencode symlink 狀態檢查
- 在 `uninstall` target 新增 opencode symlink 清理
- 在 `help` 輸出新增 opencode 說明

## Capabilities

### New Capabilities
- `opencode-commands-symlink`: OpenCode commands 透過 symlink 指向 dotfiles/claude/commands，與 Claude Code 共用

### Modified Capabilities
（無，現有 specs 無需變更）

## Impact

- **Makefile**: 新增 target、修改 install/uninstall/check/help
- **`~/.config/opencode/`**: 新增目錄與 symlink
- **OpenCode**: commands 將可透過 symlink 使用
