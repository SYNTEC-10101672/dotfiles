## Why

Claude Code 完成任務時 tmux window bar 會顯示 `✓`，但當 Claude Code 出現需要使用者回應的對話框（permission dialog、主動提問）時，window bar 沒有任何視覺變化，使用者無法從其他 window 得知需要回去處理。

## What Changes

- 新增 `Notification` hook（處理 permission dialog）在 window bar 顯示 `?`
- 新增 `PreToolUse` hook（matcher: `AskUserQuestion`）在 window bar 顯示 `?`
- 新增 script `claude-notify-waiting.sh` 設定等待狀態
- 新增 script `claude-notify-clear.sh` 清除狀態
- 修改 `claude-notify-stop.sh` 改用 `@claude_state` window option 驅動 `✓` 顯示
- **BREAKING**: 修改 tmux `window-status-format`，從 `window_bell_flag` 改為讀取 `@claude_state` window option

## Capabilities

### New Capabilities

- `claude-waiting-indicator`: 當 Claude Code 等待使用者回應時，在 tmux window bar 顯示 `?` 指示符

### Modified Capabilities

- `claude-task-notify`: tmux status bar 格式從 `window_bell_flag` 改為 `@claude_state` window option 驅動，以支援多種狀態顯示

## Impact

- `.claude/scripts/claude-notify-stop.sh` — 修改，改用 `@claude_state`
- `.claude/scripts/claude-notify-waiting.sh` — 新增
- `.claude/scripts/claude-notify-clear.sh` — 新增
- `.claude/settings.json` — 新增 `Notification` 和 `PreToolUse` hooks
- `.tmux.conf` — 修改 `window-status-format`
