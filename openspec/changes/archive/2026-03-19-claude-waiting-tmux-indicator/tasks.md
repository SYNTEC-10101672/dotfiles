## 1. Scripts

- [x] 1.1 修改 `claude-notify-stop.sh`：新增 `tmux set-window-option -t "$TMUX_PANE" @claude_state "done"`，保留原有 BEL 發送邏輯
- [x] 1.2 新增 `claude-notify-waiting.sh`：設定 `@claude_state "waiting"` + 發送 BEL，結構與 `claude-notify-stop.sh` 相同
- [x] 1.3 新增 `claude-notify-clear.sh`：讀取 stdin JSON，若 `tool_name` 為 `AskUserQuestion` 則跳過，否則將 `@claude_state` 設為 `""`

## 2. tmux 設定

- [x] 2.1 修改 `.tmux.conf` 第 143 行 `window-status-format`，將 `#{?window_bell_flag,...}` 替換為讀取 `@claude_state` 的巢狀條件式，`done` 顯示 colour46 的 `✓`，`waiting` 顯示 colour46 的 `?`
- [x] 2.2 在 `.tmux.conf` 加入 `set-hook -g after-select-window 'set-window-option @claude_state ""'`，切換 window 時自動清除指示符

## 3. Claude Code hooks

- [x] 3.1 修改 `.claude/settings.json`，在 `Notification` hook 加入 `claude-notify-waiting.sh`（空 matcher）
- [x] 3.2 修改 `.claude/settings.json`，在 `PreToolUse` 新增兩個群組：matcher `AskUserQuestion` 執行 `claude-notify-waiting.sh`，空 matcher 執行 `claude-notify-clear.sh`

## 4. 驗證

- [x] 4.1 測試 Stop hook：完成一個任務後確認 window bar 顯示 `✓`
- [x] 4.2 測試 Notification hook：觸發 permission dialog，確認 window bar 顯示 `?`
- [x] 4.3 測試 AskUserQuestion：Claude 主動問問題時確認 window bar 顯示 `?`
- [x] 4.4 測試清除：使用者回應後 Claude 開始使用其他 tool，確認指示符消失
- [x] 4.5 確認 `AskUserQuestion` 的 PreToolUse 不會觸發 clear script（`@claude_state` 維持 `"waiting"`）
