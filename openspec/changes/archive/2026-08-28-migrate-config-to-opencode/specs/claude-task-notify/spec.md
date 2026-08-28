# Delta Spec: claude-task-notify

## REMOVED Requirements

### Requirement: 任務完成 bell 通知

**Reason**: 規範 `claude-notify-stop.sh` 由 Claude Code Stop hook 觸發的鏈結；claude CLI 退役後 hook 不存在，`claude/scripts/claude-notify-stop.sh` 刪除（`opencode/scripts/notify-stop.sh` 為內容 identical 的獨立副本，早已存在）。

**Migration**: provider 端由 `opencode-native-notify` capability 承接（`plugins/notify.ts` 於 `session.idle` 事件執行 `scripts/notify-stop.sh`：設 `@claude_state` 為 `"done"`、發送 BEL、window bar 顯示 `✓`）。

### Requirement: 指示符自動消失

**Reason**: 宿主 capability 消失。

**Migration**: tmux 消費端行為（`after-select-window` hook 清除 `@claude_state`）遷往 `opencode-native-notify` capability 的 ADDED requirement「切換到 window 時自動清除指示符」。

### Requirement: 保留 window 名稱

**Reason**: 宿主 capability 消失。

**Migration**: 遷往 `opencode-native-notify` capability 的 ADDED requirement「通知不改變 window 名稱」，約束對象改為 `opencode/scripts/notify-*.sh`。

### Requirement: tmux status bar 格式

**Reason**: 宿主 capability 消失。

**Migration**: 遷往 `opencode-native-notify` capability 的 ADDED requirement「tmux status bar 格式」（`.tmux.conf` 的 `window-status-format` 條件式渲染 `@claude_state` 指示符），內容不變。
