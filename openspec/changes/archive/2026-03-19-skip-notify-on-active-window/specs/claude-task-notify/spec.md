## MODIFIED Requirements

### Requirement: 任務完成 bell 通知
Claude Code 完成任務時（Stop 事件），若使用者**不在**該 window 上，系統 SHALL 將當前 window 的 `@claude_state` 設為 `"done"`，使 window bar 顯示綠色 `✓` 指示符，並發送 BEL 字元作為音效提示。若使用者已在該 window 上（`#{window_active}` 為 `1`），系統 SHALL NOT 設定狀態或發送 bell。

#### Scenario: 使用者不在該 window 時設定 done 狀態
- **WHEN** Claude Code 觸發 Stop hook
- **AND** `#{window_active}` 為 `0`（使用者在其他 window）
- **THEN** `claude-notify-stop.sh` 將當前 window 的 `@claude_state` 設為 `"done"`
- **THEN** `claude-notify-stop.sh` 向 pane tty 發送 BEL 字元（`\a`）
- **THEN** tmux window bar 在 window 名稱後顯示綠色 `✓`

#### Scenario: 使用者已在該 window 時跳過通知
- **WHEN** Claude Code 觸發 Stop hook
- **AND** `#{window_active}` 為 `1`（使用者已在該 window）
- **THEN** `claude-notify-stop.sh` 不修改 `@claude_state`
- **THEN** `claude-notify-stop.sh` 不發送 BEL 字元
- **THEN** tmux window bar 不顯示額外指示符

#### Scenario: 非 tmux 環境下不執行
- **WHEN** Claude Code 在非 tmux 環境觸發 Stop hook（`$TMUX` 未設定）
- **THEN** script 不輸出任何內容並正常退出，不產生錯誤
