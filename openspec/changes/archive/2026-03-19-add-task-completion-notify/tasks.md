## 1. tmux 設定

- [x] 1.1 修改 `.tmux.conf` 的 `window-status-format`，加入 `#{?window_bell_flag,#[fg=colour46]✓,}#[default]` 條件式

## 2. Stop hook script

- [x] 2.1 建立 `.claude/scripts/claude-notify-stop.sh`，內容：檢查 `$TMUX` 是否存在，是則執行 `printf '\a'`
- [x] 2.2 設定 script 為可執行（`chmod +x`）

## 3. Claude Code 設定

- [x] 3.1 更新 `~/.claude/settings.json`，在 `hooks.Stop` 陣列加入呼叫 `claude-notify-stop.sh` 的 hook

## 4. 驗證

- [x] 4.1 重新載入 tmux 設定（`tmux source ~/.tmux.conf`）
- [x] 4.2 在 tmux 非當前 window 執行 `printf '\a'`，確認該 window bar 顯示綠色 `✓`
- [x] 4.3 切換到該 window，確認 `✓` 自動消失
- [x] 4.4 在 Claude Code 完成一個任務，確認 Stop hook 正確觸發並顯示 `✓`
