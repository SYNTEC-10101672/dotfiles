## Purpose

Claude Code hook 驅動的 tmux window bar 等待指示機制。當 Claude Code 需要使用者回應（permission dialog 或 AskUserQuestion）時顯示綠色 `?`，Claude 開始處理或使用者切換到 window 時自動消失。

## Requirements

### Requirement: 等待使用者回應時顯示 ? 指示符
當 Claude Code 需要使用者回應（permission dialog 或 AskUserQuestion）時，系統 SHALL 在 tmux window bar 顯示綠色 `?` 指示符。

#### Scenario: Permission dialog 出現時顯示 ?
- **WHEN** Claude Code 觸發 `Notification` hook 且 `notification_type` 為 `permission_prompt` 或 `elicitation_dialog`
- **THEN** `claude-notify-waiting.sh` 將當前 window 的 `@claude_state` 設為 `"waiting"`
- **THEN** tmux window bar 在 window 名稱後顯示綠色 `?`

#### Scenario: 其他 Notification 類型不觸發狀態變更
- **WHEN** Claude Code 觸發 `Notification` hook 且 `notification_type` 為 `idle_prompt`、`auth_success` 或其他類型
- **THEN** `claude-notify-waiting.sh` 不執行任何狀態變更並正常退出

#### Scenario: AskUserQuestion 執行前顯示 ?
- **WHEN** Claude Code 觸發 `PreToolUse` hook 且 tool 名稱為 `AskUserQuestion`
- **THEN** `claude-notify-waiting.sh` 將當前 window 的 `@claude_state` 設為 `"waiting"`
- **THEN** tmux window bar 在 window 名稱後顯示綠色 `?`

#### Scenario: 非 tmux 環境下不執行
- **WHEN** hook 在非 tmux 環境觸發（`$TMUX` 未設定）
- **THEN** script 不輸出任何內容並正常退出，不產生錯誤

### Requirement: Claude 開始處理時清除指示符
當 Claude Code 開始使用 tool 處理（非 AskUserQuestion）時，系統 SHALL 清除 `@claude_state`，window bar 不顯示任何指示符。

#### Scenario: 一般 tool 使用前清除狀態
- **WHEN** Claude Code 觸發 `PreToolUse` hook 且 tool 名稱不是 `AskUserQuestion`
- **THEN** `claude-notify-clear.sh` 將當前 window 的 `@claude_state` 設為 `""`
- **THEN** tmux window bar 不顯示 `✓` 或 `?`

#### Scenario: AskUserQuestion 的 PreToolUse 不觸發清除
- **WHEN** Claude Code 觸發 `PreToolUse` hook 且 tool 名稱為 `AskUserQuestion`
- **THEN** `claude-notify-clear.sh` 不執行（由 script 內部讀取 stdin JSON 的 `tool_name` 排除）
- **THEN** `@claude_state` 維持 `"waiting"`

### Requirement: 切換到 window 時清除指示符
使用者切換到帶有 `?` 或 `✓` 的 window 時，系統 SHALL 自動清除 `@claude_state`，window bar 不顯示任何指示符。

#### Scenario: 切換 window 時清除狀態
- **WHEN** 使用者切換到任何 tmux window
- **THEN** tmux `after-select-window` hook 將該 window 的 `@claude_state` 設為 `""`
- **THEN** window bar 不顯示 `✓` 或 `?`
