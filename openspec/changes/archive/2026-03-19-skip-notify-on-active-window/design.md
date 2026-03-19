## Context

`claude-notify-waiting.sh` 和 `claude-notify-stop.sh` 目前在 Claude hook 觸發時無條件設定 `@claude_state` 並發送 bell。若使用者已在 Claude 的 window 上，這些通知是多餘的——使用者本來就在看。

tmux 提供 `#{window_active}` format string，在 pane 所在 window 為當前 active window 時回傳 `1`。

## Goals / Non-Goals

**Goals:**
- 使用者在 active window 時，`@claude_state` 不被修改，bell 不發送

**Non-Goals:**
- 不改變使用者不在該 window 時的行為
- 不修改 `after-select-window` 清除邏輯
- 不修改 `settings.json` 的 hook 配置

## Decisions

### 使用 `#{window_active}` 而非比較 window ID

`tmux display-message -p -t "$TMUX_PANE" '#{window_active}'` 直接回傳 `1`/`0`，一個 tmux 呼叫即可判斷，無需額外解析。

替代方案：取 `#{window_id}` 再與 `tmux display-message -p '#{window_id}'`（當前 session active window）比較——需兩次呼叫，較繁瑣。

### Guard 置於 TMUX 檢查之後、狀態設定之前

```bash
if [ -n "$TMUX" ]; then
    window_active=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}')
    [ "$window_active" = "1" ] && exit 0
    # ... set state, send bell
fi
```

Guard 在 TMUX guard 內部，避免在非 tmux 環境中多餘的呼叫。

## Risks / Trade-offs

- **多 session 場景**：`#{window_active}` 反映 pane 所在 session 的 active window，若同一 pane 被多個 session attach 且不同 session focus 不同 window，行為可能不符預期。此為邊緣案例，可接受。
