## 1. Script Implementation

- [x] 1.1 在 `claude-notify-stop.sh` 的 TMUX guard 內加入 `#{window_active}` guard（active 時 exit 0）
- [x] 1.2 在 `claude-notify-waiting.sh` 的 TMUX guard 內加入 `#{window_active}` guard（active 時 exit 0）

## 2. Verification

- [x] 2.1 在 Claude window 上完成任務 → 確認 bar 不顯示 `✓`，無 bell
- [x] 2.2 切到其他 window，再完成任務 → 確認 Claude window tab 顯示 `✓`，有 bell
- [x] 2.3 在 Claude window 上觸發 AskUserQuestion → 確認 bar 不顯示 `?`
- [x] 2.4 在其他 window 觸發 AskUserQuestion → 確認 Claude window tab 顯示 `?`
