## Why

當多個 tmux window 同時執行 Claude 任務時，無法一眼判斷哪個已完成、哪個仍在執行，需要逐一切換視窗確認狀態。

## What Changes

- 新增 `claude-notify-stop.sh`：Claude 完成任務時，發送 tmux bell（`\a`）觸發視覺提示
- 更新 `.tmux.conf`：修改 `window-status-format`，bell 觸發時在 window bar 顯示綠色 `✓`
- 更新 `~/.claude/settings.json`：設定 `Stop` hook 指向上述 script

## Capabilities

### New Capabilities
- `claude-task-notify`: Claude Code Stop hook 驅動的 tmux bell 通知機制，任務完成時在 window bar 顯示綠色 `✓`，切換視窗後自動消失

### Modified Capabilities

(none)

## Impact

- **Files added**: `.claude/scripts/claude-notify-stop.sh`
- **Files modified**: `.tmux.conf`（修改 `window-status-format`）、`~/.claude/settings.json`（新增 Stop hook）
- **Dependencies**: tmux（已存在於 server 環境）
- **Scope**: 僅影響本機 Claude Code 行為，不影響任何專案程式碼
