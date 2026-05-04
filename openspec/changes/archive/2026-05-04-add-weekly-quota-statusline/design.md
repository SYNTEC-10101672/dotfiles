## Context

現有 `claude-glm` wrapper 在背景以每 60 秒間隔 fetch Z.AI quota API，只取第一個 `TOKENS_LIMIT`（unit=3，5 小時 reset）寫入 `/tmp/glm-quota-cache.json`。`claude-code-statusline` 讀取 cache 顯示 `🔋 N% (Xh Ym)`。

Pro 方案 API 回傳 3 個 limits：unit=3（5h TOKENS_LIMIT）、unit=6（weekly TOKENS_LIMIT）、unit=5（monthly TIME_LIMIT）。

## Goals / Non-Goals

**Goals:**
- 快取同時取得 5h 與 weekly 兩個 TOKENS_LIMIT
- Statusline 新增 weekly quota 顯示（`📊` icon）
- Countdown 格式擴充支援天數（weekly 配額可能剩餘數天）

**Non-Goals:**
- 不顯示 TIME_LIMIT（月度時間配額）
- 不改變 native Claude 模式的行為
- 不改變 opencode 的 quota 顯示

## Decisions

### 1. API 解析策略：依 `unit` 欄位區分 limits

現有程式碼取 `[0]`（第一個 TOKENS_LIMIT），Pro 方案有多個。改為依 `unit` 值選取：
- unit=3 → 5h token quota（現有行為）
- unit=6 → weekly token quota（新增）

**替代方案**：依 `nextResetTime` 排序選最短/最長 — 不可靠，reset time 會隨使用量變動。`unit` 欄位是穩定的週期標識。

### 2. Cache 格式：新增欄位，保留舊欄位向後相容

```json
{
  "tokens_remaining": <int>,
  "tokens_reset_at": <epoch seconds>,
  "weekly_remaining": <int>,
  "weekly_reset_at": <epoch seconds>,
  "fetched_at": <epoch seconds>
}
```

舊欄位名稱不變，新增 `weekly_*` 兩個欄位。如果 API 未回傳 unit=6 的資料（例如降級回 Lite），weekly 欄位不寫入，statusline 靜默略過。

### 3. format_countdown 擴充

在現有小時/分鐘基礎上新增天數：
- `> 24h` → `(Xd Yh)` — 例如 `(6d23h)`
- `≤ 24h` → 現有邏輯不變

單一函數處理所有 countdown，5h 和 weekly 共用。

## Risks / Trade-offs

- **[API schema 變動]** → `unit` 欄位如果 Z.AI 改了就會解析失敗。Mitigation：fetch 失敗時靜默略過，statusline 不顯示 weekly 段，不影響核心功能。
- **[Statusline 過長]** → 多一個 quota 段會讓 tmux status bar 更長。Mitigation：weekly countdown 用精簡格式 `(Xd Yh)` 而非 `(Xd Yh Zm)`。
