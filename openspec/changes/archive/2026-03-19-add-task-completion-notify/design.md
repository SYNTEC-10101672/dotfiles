## Context

使用者透過 PowerShell SSH 連線到 Linux server，在 tmux 中開啟多個 window，每個 window 執行一個 Claude Code instance。Claude Code 提供 hooks 機制，可在特定事件時執行 shell script。

目前 `.claude/scripts/` 已有其他 scripts（statusline、greeting 等），新 scripts 放入同一目錄。`settings.json` 已有 `statusLine`、`permissions` 等設定，hooks 設定需新增至此檔案。

## Goals / Non-Goals

**Goals:**
- Claude 完成任務時，tmux window bar 顯示綠色 `✓`
- 切換到該 window 時，`✓` 自動消失
- 不修改 window 名稱
- Scripts 放入 `.dotfiles` git 追蹤範圍

**Non-Goals:**
- 非 tmux 環境的通知（e.g., desktop notification、sound）
- 跨 SSH session 的通知推送

## Decisions

### 使用 tmux bell + window-status-format 條件式

**機制：**
1. Stop hook 執行 `claude-notify-stop.sh`，發送 `printf '\a'`（BEL 字元）
2. tmux 接收 BEL，設定該 window 的 `window_bell_flag`
3. `window-status-format` 使用條件式，bell flag 存在時顯示綠色 `✓`
4. 使用者切換到該 window 時，tmux 自動清除 bell flag，`✓` 消失

**`.tmux.conf` 修改：**
```
# window-status-format：bell flag 存在時顯示綠色 ✓
舊：' #I:#W#F '
新：' #I:#W#{?window_bell_flag,#[fg=colour46]✓,}#[default] '

# window-status-bell-style：bell 時保持綠字（與 activity style 一致）
新增：setw -g window-status-bell-style fg=colour154,bg=colour234
```

`window-status-bell-style` 必須明確設定，否則 tmux 預設會套用粉色底色。設成與 `window-status-activity-style` 相同的綠字，視覺一致。

**選擇理由：**
- 狀態由 tmux 原生管理，不需要第二個 script 或 `UserPromptSubmit` hook
- 不修改 window 名稱，保持乾淨
- 切換視窗自動清除，符合直覺

**替代方案考慮：**
- rename window 加 `✓` 前綴：需要 2 個 scripts + 2 個 hooks，且 `✓` 顏色無法單獨控制

### 只需要一個 script（Stop hook）

`claude-notify-start.sh` 不再需要，因為 bell flag 由 tmux 自己管理生命週期。`UserPromptSubmit` hook 也不需要。

### 環境檢查：只在 tmux 內執行，且必須指定自身 pane

Script 需要先確認 `$TMUX` 環境變數存在。bell 字元必須寫入 **Claude Code 自身所在 pane 的 TTY**，使用 `$TMUX_PANE` 指定：

```bash
[ -n "$TMUX" ] && printf '\a' > "$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}')"
```

不使用 `-t` 指定 pane 時，`tmux display-message` 回傳當前活躍 window 的 pane TTY。若使用者已切換到其他 window 等待，bell 會被送到使用者所在的 window，觸發後立即被清掉，導致 `✓` 無法顯示。

### hooks 設定放在 `~/.claude/settings.json`（global）

通知功能是環境層級的行為，不屬於任何特定 project，放 global 正確。

## Risks / Trade-offs

- **activity 與 bell 並存**：`monitor-activity on` 開啟時，Claude 執行中 window 已有 activity 樣式（綠字）。bell 觸發後兩者可能同時存在，但使用者表示平常不看 activity 高亮，無衝突疑慮
- **非 tmux 環境**：若在非 tmux 環境執行 Claude，script 需優雅退出（加 `$TMUX` 檢查）
- **bell 視覺效果取決於 terminal**：SSH 透過 PowerShell 時，`printf '\a'` 的 bell 字元由 tmux 攔截處理，不會傳到 Windows terminal，行為可預期
