## 1. 實作

- [x] 1.1 在 `.claude/scripts/claude-code-statusline` 新增 `RATE_LIMIT_USED` 變數，使用 `jq` 解析 `rate_limits.five_hour.used_percentage // empty`
- [x] 1.2 新增 `RATE_LIMIT_RESETS_AT` 變數，使用 `jq` 解析 `rate_limits.five_hour.resets_at // empty`
- [x] 1.3 當 `RATE_LIMIT_RESETS_AT` 非空時，以 `$(date +%s)` 計算剩餘秒數，轉換為 `Xh Ym` 或 `Ym` 格式
- [x] 1.4 新增 `RATE_LIMIT_DISPLAY` 條件區塊，當 `RATE_LIMIT_USED` 非空時組合輸出 ` | 🔋 N%` 或 ` | 🔋 N% (Xh Ym)`
- [x] 1.5 將 `$RATE_LIMIT_DISPLAY` 附加至最後的 `echo` 輸出行

## 2. 驗證

- [x] 2.1 以包含 `used_percentage` 與 `resets_at`（剩餘 > 1 小時）的模擬 JSON 測試，確認 `🔋 N% (Xh Ym)` 格式正確
- [x] 2.2 以剩餘時間 < 1 小時的模擬 JSON 測試，確認省略小時顯示 `🔋 N% (Ym)`
- [x] 2.3 以有 `used_percentage` 但無 `resets_at` 的模擬 JSON 測試，確認退化為 `🔋 N%`
- [x] 2.4 以不含 `rate_limits` 欄位的模擬 JSON 測試，確認無錯誤且欄位靜默省略
- [x] 2.5 在實際 Claude Code session 中目視確認 statusline 顯示正常
