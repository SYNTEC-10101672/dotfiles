## Why

當通知觸發（`✓` 或 `?`）時，若使用者已在 Claude 的 window 上，指示符出現是多餘的——使用者本來就在看，不需要提醒。指示符的唯一價值是在使用者**不在**該 window 時通知他們切過去。

## What Changes

- `claude-notify-waiting.sh` 在設定 `@claude_state` 和發送 bell 前，先檢查 pane 所在的 window 是否為當前 active window；若是，直接 exit
- `claude-notify-stop.sh` 同上

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `claude-task-notify`: 新增「active window 時跳過通知」行為——Stop hook 觸發但使用者已在該 window 時不設定 `@claude_state` 也不發 bell
- `claude-waiting-indicator`: 同上，適用於 `?` 指示符（permission dialog / AskUserQuestion）

## Impact

- `.claude/scripts/claude-notify-waiting.sh`
- `.claude/scripts/claude-notify-stop.sh`
