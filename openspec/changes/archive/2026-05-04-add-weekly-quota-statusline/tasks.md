## 測試

- [x] T1 驗證 claude-glm 背景快取寫入 weekly 欄位
  > 指令：執行 `claude-glm --version`，等待 5 秒後檢查 `/tmp/glm-quota-cache.json` 內容
  > 預期：快取包含 `weekly_remaining` 與 `weekly_reset_at` 欄位，值為整數，`weekly_reset_at` 為 epoch seconds

- [x] T2 驗證 format_countdown 天數顯示
  > 指令：在 bash 中 source statusline script 後執行 `format_countdown $(( $(date +%s) + 172800 ))`（2 天後）
  > 預期：輸出 `(2d0h)`

- [x] T3 驗證 format_countdown 天+小時顯示
  > 指令：執行 `format_countdown $(( $(date +%s) + 90000 ))`（約 1 天 1 小時）
  > 預期：輸出 `(1d1h)`

- [x] T4 驗證 format_countdown 現有格式不變（不足 24h）
  > 指令：執行 `format_countdown $(( $(date +%s) + 7200 ))`（2 小時）
  > 預期：輸出 `(2h0m)`

- [x] T5 驗證 statusline GLM 模式顯示 weekly quota
  > 指令：設定 `CLAUDE_PROXY_MODE=glm`，準備含 weekly 欄位的 cache，透過 stdin 傳入 JSON 測試 statusline 輸出
  > 預期：輸出包含 `📊` icon 及 weekly 百分比與 countdown

- [x] T6 驗證 statusline 無 weekly 欄位時不顯示
  > 指令：設定 `CLAUDE_PROXY_MODE=glm`，準備不含 weekly 欄位的 cache（僅有 `tokens_remaining`），測試 statusline 輸出
  > 預期：輸出包含 `🔋` 但不包含 `📊`

- [x] T7 驗證 statusline native 模式不受影響
  > 指令：不設定 `CLAUDE_PROXY_MODE`，透過 stdin 傳入 JSON 測試 statusline 輸出
  > 預期：輸出不包含 `🔋` 也不包含 `📊`，行為與修改前相同

## 實作

- [x] 1.1 擴充 `claude-glm` 背景 fetch 邏輯，依 `unit` 欄位分別取得 unit=3（5h）與 unit=6（weekly）的 TOKENS_LIMIT，寫入 cache（→ T1）

- [x] 1.2 擴充 `format_countdown` 函數支援天數：超過 24 小時時格式為 `(Xd Yh)`（→ T2, T3, T4）

- [x] 1.3 擴充 `claude-code-statusline` 讀取 weekly 欄位並顯示 `📊 N% (countdown)`（→ T5, T6）

- [x] 1.4 確認 native 模式行為不受影響（→ T7）
