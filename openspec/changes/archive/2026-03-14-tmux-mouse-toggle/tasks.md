## 1. 實作

- [x] 1.1 在 `.tmux.conf` 的 Key Bindings 區段新增 `bind M set -g mouse \; display "Mouse: #{?mouse,ON,OFF}"`

## 2. 驗證

- [x] 2.1 重新載入 tmux config (`tmux source ~/.tmux.conf`)，確認 `Ctrl-b M` 可正常 toggle
- [x] 2.2 確認切換時 display-message 正確顯示 ON / OFF
