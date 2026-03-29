## 1. tmux 設定

- [x] 1.1 在 `.tmux.conf` 的 Copy Mode Settings 區塊加入 `set -g allow-passthrough on`
- [x] 1.2 修改 `.tmux.conf` 的 `y` binding，改為 `copy-pipe-and-cancel` inline DCS-wrapped OSC 52

## 2. Neovim 剪貼簿設定

- [x] 2.1 在 `.nvim/lua/config/clipboard.lua` 將 `io.open('/dev/tty', 'w')` 的寫入邏輯改為 `io.stdout:write()` + `io.stdout:flush()`

## 3. 驗證

- [x] 3.1 在 iPad + Blink Shell + SSH + tmux 環境：進入 copy mode，選取文字按 `y`，確認能貼至其他 app
- [x] 3.2 在 iPad + Blink Shell + SSH + tmux 環境：於 neovim 執行 yank，確認能貼至其他 app
- [x] 3.3 在 Windows Terminal + PowerShell + SSH + tmux 環境：確認 tmux copy mode 與 neovim yank 功能不受影響
