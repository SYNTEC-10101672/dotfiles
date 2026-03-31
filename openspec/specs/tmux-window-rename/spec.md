## ADDED Requirements

### Requirement: 啟動時重新命名 tmux window
`claude-glm` 包裝腳本 SHALL 在啟動 `claude` 前將當前 tmux window 重新命名為 "claude-glm"，但僅限於在 tmux session 中執行時。

#### Scenario: 在 tmux 中啟動
- **WHEN** 使用者在 tmux session 中執行 `claude-glm`
- **THEN** tmux window name 在 `claude` 啟動前被設為 "claude-glm"

#### Scenario: 在 tmux 外啟動
- **WHEN** 使用者在 tmux 外執行 `claude-glm`
- **THEN** 不會嘗試重新命名，`claude` 正常啟動
