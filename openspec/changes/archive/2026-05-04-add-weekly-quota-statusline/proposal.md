## Why

GLM 方案從 Lite 升級到 Pro 後，Z.AI API 多了 weekly token quota（`TOKENS_LIMIT` unit=6）與 monthly time limit（`TIME_LIMIT` unit=5）。現有 statusline 只顯示 5 小時 token quota，需要擴充以支援 weekly quota 顯示。

## What Changes

- `claude-glm` 背景快取機制擴充為同時取得 5 小時與 weekly 兩個 `TOKENS_LIMIT`，寫入 cache
- `claude-code-statusline` 新增 weekly quota 顯示段（`📊` icon），格式為 `| 📊 N% (Xd Yh)`
- `format_countdown` 函數擴充支援天數顯示
- 不顯示 `TIME_LIMIT`（月度時間配額即時監控價值低）

## Capabilities

### New Capabilities

（無）

### Modified Capabilities
- `glm-quota-display`: 擴充支援多個 `TOKENS_LIMIT`（5h + weekly），cache 格式新增 weekly 欄位，statusline 新增 weekly 顯示段，`format_countdown` 支援天數

## Impact

- `claude/scripts/claude-glm` — 背景 fetch 邏輯與 cache 格式
- `claude/scripts/claude-code-statusline` — 讀取 cache 邏輯與顯示格式
- `/tmp/glm-quota-cache.json` — 新增 `weekly_remaining`、`weekly_reset_at` 欄位（向後相容，舊欄位保留）
