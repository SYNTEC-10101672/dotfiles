## 動機

Claude Code 的 statusline 目前無法顯示額度使用情況，使用者無法在觸碰 5 小時限制前預先察覺。Claude Code API 現已在 statusline 的 JSON 輸入中提供 `rate_limits` 資料，可以直接取用並顯示。

## 變更內容

- 從 statusline JSON 輸入解析 `rate_limits.five_hour.used_percentage` 與 `rate_limits.five_hour.resets_at`
- 以 `🔋 N% (Xh Ym)` 格式附加顯示在現有 statusline 輸出末端；不足 1 小時時省略小時，顯示 `(Ym)`
- `resets_at` 不存在時退化為只顯示 `🔋 N%`
- 當 `rate_limits` 欄位完全不存在時靜默跳過（非 Pro/Max 帳戶，或 session 首次 API 回應前）

## Capabilities

### 新增 Capabilities

- `statusline-rate-limit`：在 statusline 顯示 Claude.ai 5 小時額度使用百分比與剩餘重置時間

### 修改 Capabilities

- 無

## 影響範圍

- **檔案**：`.claude/scripts/claude-code-statusline` — 新增額度解析與顯示邏輯
- **無 breaking changes**：純新增，現有 statusline 格式不變，有資料時才附加顯示
- **相依套件**：`jq`（現有 script 已使用）
