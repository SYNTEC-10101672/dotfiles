## 背景

Claude Code statusline 是一個 bash script（`.claude/scripts/claude-code-statusline`），透過 stdin 接收 JSON 並輸出單行文字。現已解析 `model`、`workspace`、`context_window` 等欄位。Claude Code 現在對 Pro/Max 訂閱者在此 JSON 中提供 `rate_limits` 物件，包含 5 小時與 7 天的使用資料。

## 目標 / 非目標

**目標：**
- 在 statusline 顯示 5 小時額度使用量（`used_percentage`）
- 顯示距離 reset 的剩餘時間（由 `resets_at` Unix timestamp 計算）
- 當欄位不存在時靜默跳過，不產生錯誤輸出

**非目標：**
- 顯示 7 天窗口資料
- 顯示剩餘（反向）百分比

## 技術決策

**使用 `jq` 搭配 `// empty` fallback**

現有 script 已全面使用 `jq` 解析 JSON。`.rate_limits.five_hour.used_percentage // empty` 在欄位不存在時回傳空字串，與現有 `CONTEXT_DISPLAY` 的條件顯示模式完全一致。

備選方案：`// "null"` 搭配字串比較 — 捨棄，因為 `// empty` 不產生任何輸出，條件判斷更簡潔。

**顯示格式：`🔋 N% (Xh Ym)` / `🔋 N% (Ym)`**

與現有 `🧠 N%`（context window）格式一致。電池符號直觀傳達「容量消耗」概念，即使顯示的是已用百分比。

剩餘時間由 `resets_at - $(date +%s)` 計算，格式規則：
- 剩餘 ≥ 1 小時：顯示 `(Xh Ym)`
- 剩餘 < 1 小時：只顯示 `(Ym)`，省略小時
- `resets_at` 不存在：退化為只顯示 `🔋 N%`，無括號時間

**附加在 statusline 末端**

保持現有欄位順序不變。額度資訊變動頻率最低，適合放在最後。

## 風險 / 取捨

- **欄位在 session 中途才出現**：`rate_limits` 在首次 API 回應前不存在。`// empty` fallback 可透明處理此情況。
- **僅限 Pro/Max**：免費帳戶永遠看不到此欄位，靜默不顯示是正確的 UX。

## 部署計畫

不需要 migration — 純粹對本機 script 的新增變更。無需 rollback 計畫，回退只需刪除幾行程式碼。
