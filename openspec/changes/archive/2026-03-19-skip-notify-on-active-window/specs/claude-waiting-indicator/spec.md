## MODIFIED Requirements

### Requirement: 等待使用者回應時顯示 ? 指示符
當 Claude Code 需要使用者回應（permission dialog 或 AskUserQuestion）時，若使用者**不在**該 window 上，系統 SHALL 在 tmux window bar 顯示綠色 `?` 指示符。若使用者已在該 window 上（`#{window_active}` 為 `1`），系統 SHALL NOT 設定狀態或發送 bell。

#### Scenario: Permission dialog 出現且使用者不在該 window 時顯示 ?
- **WHEN** Claude Code 觸發 `Notification` hook 且 `notification_type` 為 `permission_prompt` 或 `elicitation_dialog`
- **AND** `#{window_active}` 為 `0`（使用者在其他 window）
- **THEN** `claude-notify-waiting.sh` 將當前 window 的 `@claude_state` 設為 `"waiting"`
- **THEN** tmux window bar 在 window 名稱後顯示綠色 `?`

#### Scenario: Permission dialog 出現但使用者已在該 window 時跳過
- **WHEN** Claude Code 觸發 `Notification` hook 且 `notification_type` 為 `permission_prompt` 或 `elicitation_dialog`
- **AND** `#{window_active}` 為 `1`（使用者已在該 window）
- **THEN** `claude-notify-waiting.sh` 不修改 `@claude_state`，不發送 bell
- **THEN** tmux window bar 不顯示額外指示符

#### Scenario: AskUserQuestion 執行前且使用者不在該 window 時顯示 ?
- **WHEN** Claude Code 觸發 `PreToolUse` hook 且 tool 名稱為 `AskUserQuestion`
- **AND** `#{window_active}` 為 `0`
- **THEN** `claude-notify-waiting.sh` 將當前 window 的 `@claude_state` 設為 `"waiting"`
- **THEN** tmux window bar 在 window 名稱後顯示綠色 `?`

#### Scenario: AskUserQuestion 執行前但使用者已在該 window 時跳過
- **WHEN** Claude Code 觸發 `PreToolUse` hook 且 tool 名稱為 `AskUserQuestion`
- **AND** `#{window_active}` 為 `1`
- **THEN** `claude-notify-waiting.sh` 不修改 `@claude_state`，不發送 bell

#### Scenario: 其他 Notification 類型不觸發狀態變更
- **WHEN** Claude Code 觸發 `Notification` hook 且 `notification_type` 為 `idle_prompt`、`auth_success` 或其他類型
- **THEN** `claude-notify-waiting.sh` 不執行任何狀態變更並正常退出

#### Scenario: 非 tmux 環境下不執行
- **WHEN** hook 在非 tmux 環境觸發（`$TMUX` 未設定）
- **THEN** script 不輸出任何內容並正常退出，不產生錯誤
