# Delta Spec: claude-waiting-indicator

## REMOVED Requirements

### Requirement: 等待使用者回應時顯示 ? 指示符

**Reason**: 規範 `claude-notify-waiting.sh` 由 Claude Code `Notification`/`PreToolUse` hooks 觸發的鏈結；claude CLI 退役後 hooks 不存在，`claude/scripts/claude-notify-waiting.sh` 刪除（`opencode/scripts/notify-waiting.sh` 為內容 identical 的獨立副本，早已存在）。

**Migration**: provider 端由 `opencode-native-notify` capability 承接（`plugins/notify.ts` 於 `permission.asked` 事件與 `question` tool 的 `tool.execute.before` hook 執行 `scripts/notify-waiting.sh`：設 `@claude_state` 為 `"waiting"`、window bar 顯示 `?`）。

### Requirement: Claude 開始處理時清除指示符

**Reason**: 規範 `claude-notify-clear.sh`（PreToolUse hook 驅動）；此 script 從未存在於 repo（規格先行、實作未落地），claude hooks 鏈亦退役。

**Migration**: 無承接（opencode 端以狀態覆蓋語意處理：下次 `notify-stop.sh` 或 `notify-waiting.sh` 執行時覆寫 `@claude_state`，`after-select-window` 清除）。

### Requirement: 切換到 window 時清除指示符

**Reason**: 宿主 capability 消失。

**Migration**: tmux 消費端行為遷往 `opencode-native-notify` capability 的 ADDED requirement「切換到 window 時自動清除指示符」（與 `claude-task-notify` 的「指示符自動消失」合併為同一 requirement）。
