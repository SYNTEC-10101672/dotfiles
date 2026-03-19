## Purpose

Claude Code Stop hook 驅動的 tmux bell 通知機制。任務完成時在 window bar 顯示綠色 `✓`，切換到該 window 後自動消失，不修改 window 名稱。

## Requirements

### Requirement: 任務完成 bell 通知
Claude Code 完成任務時（Stop 事件），系統 SHALL 向當前 tmux window 發送 bell 訊號，使 window bar 在 window 名稱後顯示綠色 `✓` 指示符。

#### Scenario: 任務完成時發送 bell
- **WHEN** Claude Code 觸發 Stop hook
- **THEN** stop script 向 stdout 發送 BEL 字元（`\a`）
- **THEN** tmux 在當前 window 設定 bell flag
- **THEN** window bar 在 window 名稱後顯示綠色 `✓`

#### Scenario: 非 tmux 環境下不執行
- **WHEN** Claude Code 在非 tmux 環境觸發 Stop hook（`$TMUX` 未設定）
- **THEN** script 不輸出任何內容並正常退出，不產生錯誤

### Requirement: 指示符自動消失
使用者切換到已通知的 window 時，綠色 `✓` 指示符 SHALL 自動消失。

#### Scenario: 切換視窗時自動清除
- **WHEN** 使用者切換到帶有 bell flag 的 window
- **THEN** tmux 自動清除該 window 的 bell flag
- **THEN** window bar 不再顯示 `✓`

### Requirement: 保留 window 名稱
系統 SHALL NOT 在通知或消除過程中修改 tmux window 名稱。

#### Scenario: 通知後 window 名稱不變
- **WHEN** Claude Code 觸發 Stop hook
- **THEN** window 名稱與 hook 執行前完全相同

### Requirement: tmux status bar 格式
tmux 的 `window-status-format` SHALL 在 window bell flag 存在時條件式渲染綠色 `✓` 字元，flag 不存在時不渲染任何額外字元。

#### Scenario: bell flag 存在時顯示 ✓
- **WHEN** window 帶有 bell flag
- **THEN** window bar 顯示 `#I:#W✓`，其中 `✓` 使用 colour46（亮綠色）

#### Scenario: 無 bell flag 時不顯示額外字元
- **WHEN** window 不帶有 bell flag
- **THEN** window bar 顯示 `#I:#W`，無任何附加字元
