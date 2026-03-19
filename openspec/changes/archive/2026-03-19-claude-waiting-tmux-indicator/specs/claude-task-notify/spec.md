## MODIFIED Requirements

### Requirement: tmux status bar 格式
tmux 的 `window-status-format` SHALL 讀取 `@claude_state` window option，條件式渲染對應指示符：`@claude_state` 為 `"done"` 時顯示綠色 `✓`，為 `"waiting"` 時顯示綠色 `?`，其餘不顯示任何額外字元。

#### Scenario: @claude_state 為 done 時顯示 ✓
- **WHEN** window 的 `@claude_state` 為 `"done"`
- **THEN** window bar 顯示 `#I:#W✓`，其中 `✓` 使用 colour46（亮綠色）

#### Scenario: @claude_state 為 waiting 時顯示 ?
- **WHEN** window 的 `@claude_state` 為 `"waiting"`
- **THEN** window bar 顯示 `#I:#W?`，其中 `?` 使用 colour46（亮綠色）

#### Scenario: @claude_state 為空時不顯示額外字元
- **WHEN** window 的 `@claude_state` 為 `""` 或未設定
- **THEN** window bar 顯示 `#I:#W`，無任何附加字元

### Requirement: 任務完成 bell 通知
Claude Code 完成任務時（Stop 事件），系統 SHALL 將當前 window 的 `@claude_state` 設為 `"done"`，使 window bar 顯示綠色 `✓` 指示符，並發送 BEL 字元作為音效提示。

#### Scenario: 任務完成時設定 done 狀態
- **WHEN** Claude Code 觸發 Stop hook
- **THEN** `claude-notify-stop.sh` 將當前 window 的 `@claude_state` 設為 `"done"`
- **THEN** `claude-notify-stop.sh` 向 pane tty 發送 BEL 字元（`\a`）
- **THEN** tmux window bar 在 window 名稱後顯示綠色 `✓`

#### Scenario: 非 tmux 環境下不執行
- **WHEN** Claude Code 在非 tmux 環境觸發 Stop hook（`$TMUX` 未設定）
- **THEN** script 不輸出任何內容並正常退出，不產生錯誤
