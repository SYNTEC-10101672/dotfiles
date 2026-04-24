## ADDED Requirements

### Requirement: claude-glm 啟動時背景 fetch Z.ai quota 並快取
`claude-glm` SHALL 在啟動後以背景子程序呼叫 Z.ai quota API（`GET https://api.z.ai/api/monitor/usage/quota/limit`），使用 `GLM_API_KEY` 作為 Bearer token，並將結果解析後寫入 `/tmp/glm-quota-cache.json`。Fetch 失敗時 SHALL 靜默略過，不中斷啟動流程。

快取檔案格式：
```json
{
  "tokens_remaining": <integer 0-100>,
  "tokens_reset_at": <epoch seconds integer>,
  "fetched_at": <epoch seconds integer>
}
```

`tokens_remaining` SHALL 為 `100 - data.limits[type=TOKENS_LIMIT].percentage`（無條件捨去）。
`tokens_reset_at` SHALL 為 `data.limits[type=TOKENS_LIMIT].nextResetTime / 1000`（epoch ms 轉 seconds）。

#### Scenario: API fetch 成功
- **WHEN** `claude-glm` 啟動且 Z.ai API 回傳 200 含 TOKENS_LIMIT 資料
- **THEN** `/tmp/glm-quota-cache.json` 被建立或覆寫，包含 `tokens_remaining`、`tokens_reset_at`、`fetched_at` 三個欄位

#### Scenario: API fetch 失敗
- **WHEN** `claude-glm` 啟動但 Z.ai API 呼叫失敗（網路錯誤、非 200 回應等）
- **THEN** `/tmp/glm-quota-cache.json` 不被修改，`claude-glm` 正常繼續啟動，不輸出錯誤至 stdout

#### Scenario: 無 TOKENS_LIMIT 資料
- **WHEN** API 回應不包含 `type=TOKENS_LIMIT` 的 limits 項目
- **THEN** `/tmp/glm-quota-cache.json` 不被修改，fetch 靜默略過

### Requirement: statusline 在 GLM 模式下顯示 TOKENS_LIMIT 剩餘配額與 reset 倒數
`claude-code-statusline` SHALL 在 `CLAUDE_PROXY_MODE=glm` 時讀取 `/tmp/glm-quota-cache.json`，使用 `tokens_remaining` 與 `tokens_reset_at` 產生與 `statusline-rate-limit` 相同格式的 quota 顯示段（`| 🔋 N% (Xh Ym)` 或 `| 🔋 N% (Ym)`）。快取不存在時 SHALL 靜默略過，不輸出錯誤。

#### Scenario: 快取存在且剩餘時間超過 1 小時
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在，`tokens_reset_at` 距現在超過 1 小時
- **THEN** statusline 包含 ` | 🔋 N% (Xh Ym)`（N 為剩餘百分比，X 為剩餘小時，Y 為剩餘分鐘）

#### Scenario: 快取存在且剩餘時間不足 1 小時
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在，`tokens_reset_at` 距現在不足 1 小時
- **THEN** statusline 包含 ` | 🔋 N% (Ym)`，省略小時部分

#### Scenario: 快取存在但 reset 時間已過
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在，`tokens_reset_at` 早於現在時間
- **THEN** statusline 顯示 ` | 🔋 N%`，不顯示括號時間

#### Scenario: 快取不存在
- **WHEN** `CLAUDE_PROXY_MODE=glm`，`/tmp/glm-quota-cache.json` 不存在
- **THEN** statusline 完全略過 quota 欄位，不產生任何錯誤輸出

#### Scenario: native 模式不受影響
- **WHEN** `CLAUDE_PROXY_MODE` 未設定（native 模式）
- **THEN** statusline 行為與修改前完全相同，不讀取 GLM cache
