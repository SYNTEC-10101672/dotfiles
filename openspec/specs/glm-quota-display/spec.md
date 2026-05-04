# GLM Quota Display

## Purpose

提供 GLM (Z.ai) 模式下的 token quota 顯示功能，包含背景快取機制與 statusline 整合。

## Requirements

### Requirement: claude-glm 啟動時背景 fetch Z.ai quota 並快取
`claude-glm` SHALL 在啟動後以背景子程序呼叫 Z.ai quota API（`GET https://api.z.ai/api/monitor/usage/quota/limit`），使用 `GLM_API_KEY` 作為 Bearer token，並將結果解析後寫入 `/tmp/glm-quota-cache.json`。Fetch 失敗時 SHALL 靜默略過，不中斷啟動流程。

背景子程序 SHALL 以每 1 分鐘（60 秒）的間隔持續重新 fetch 並更新快取，直到 session 結束。單次 fetch 失敗時 SHALL 不中斷 loop，繼續等待下一個間隔。

背景子程序的 stdout 與 stderr SHALL 重定向至 `/dev/null`，確保不繼承 parent process 的 pipe 或 terminal file descriptors。此隔離防止在 command substitution（`$(...)`）等場景下，背景子程序持有 pipe write-end 導致 caller 永遠等不到 EOF。

背景子程序 SHALL 從 `data.limits` 陣列中依 `unit` 欄位選取兩個 `TOKENS_LIMIT`：
- `unit=3` → 5 小時 token quota，對應快取欄位 `tokens_remaining` 與 `tokens_reset_at`
- `unit=6` → weekly token quota，對應快取欄位 `weekly_remaining` 與 `weekly_reset_at`

當 API 回傳的 limits 陣列不包含特定 unit 時，對應的快取欄位 SHALL 不寫入（保留上次值或不存在）。

快取檔案格式：
```json
{
  "tokens_remaining": <integer 0-100>,
  "tokens_reset_at": <epoch seconds integer>,
  "weekly_remaining": <integer 0-100>,
  "weekly_reset_at": <epoch seconds integer>,
  "fetched_at": <epoch seconds integer>
}
```

`tokens_remaining` SHALL 為 `100 - data.limits[type=TOKENS_LIMIT, unit=3].percentage`（無條件捨去）。
`tokens_reset_at` SHALL 為 `data.limits[type=TOKENS_LIMIT, unit=3].nextResetTime / 1000`（epoch ms 轉 seconds）。
`weekly_remaining` SHALL 為 `100 - data.limits[type=TOKENS_LIMIT, unit=6].percentage`（無條件捨去）。
`weekly_reset_at` SHALL 為 `data.limits[type=TOKENS_LIMIT, unit=6].nextResetTime / 1000`（epoch ms 轉 seconds）。

#### Scenario: API fetch 成功（Pro 方案，含 weekly quota）
- **WHEN** `claude-glm` 啟動且 Z.ai API 回傳 200 含 unit=3 與 unit=6 的 TOKENS_LIMIT 資料
- **THEN** `/tmp/glm-quota-cache.json` 被建立或覆寫，包含 `tokens_remaining`、`tokens_reset_at`、`weekly_remaining`、`weekly_reset_at`、`fetched_at` 五個欄位

#### Scenario: 定期更新
- **WHEN** `claude-glm` session 持續運行超過 1 分鐘
- **THEN** 背景子程序再次呼叫 API 並更新 `/tmp/glm-quota-cache.json`，`fetched_at` 欄位反映最新 fetch 時間

#### Scenario: API fetch 失敗
- **WHEN** `claude-glm` 啟動但 Z.ai API 呼叫失敗（網路錯誤、非 200 回應等）
- **THEN** `/tmp/glm-quota-cache.json` 不被修改，`claude-glm` 正常繼續啟動，不輸出錯誤至 stdout；背景 loop 繼續等待下一個間隔

#### Scenario: 無 TOKENS_LIMIT 資料
- **WHEN** API 回應不包含 `type=TOKENS_LIMIT` 的 limits 項目
- **THEN** `/tmp/glm-quota-cache.json` 不被修改，fetch 靜默略過

#### Scenario: 僅有 5h quota 無 weekly（Lite 方案）
- **WHEN** API 回傳含 unit=3 但不含 unit=6 的 TOKENS_LIMIT
- **THEN** `tokens_remaining` 與 `tokens_reset_at` 正常寫入，`weekly_remaining` 與 `weekly_reset_at` 欄位不存在於快取中

#### Scenario: command substitution 呼叫不會 hang
- **WHEN** `claude-glm --version` 在 command substitution 中被呼叫（例如 `result=$(claude-glm --version 2>&1)`）
- **THEN** command substitution 在 `claude --version` 輸出結果後正常返回，不會因為背景 quota loop 持有 pipe fd 而永久阻塞

### Requirement: statusline 在 GLM 模式下顯示 TOKENS_LIMIT 剩餘配額與 reset 倒數
`claude-code-statusline` SHALL 在 `CLAUDE_PROXY_MODE=glm` 時讀取 `/tmp/glm-quota-cache.json`，使用 `tokens_remaining` 與 `tokens_reset_at` 產生與 `statusline-rate-limit` 相同格式的 quota 顯示段（`| 🔋 N% (Xh Ym)` 或 `| 🔋 N% (Ym)`）。快取不存在時 SHALL 靜默略過，不輸出錯誤。

`claude-code-statusline` SHALL 在 `CLAUDE_PROXY_MODE=glm` 且快取包含 `weekly_remaining` 與 `weekly_reset_at` 時，在 5h quota 顯示段之後追加 weekly quota 顯示段（`| 📊 N% (Xd Yh)` 或 `| 📊 N% (Yh)` 或 `| 📊 N% (Ym)`）。快取不含 weekly 欄位時 SHALL 靜默略過 weekly 顯示段。

`format_countdown` 函數 SHALL 支援天數顯示：當剩餘時間超過 24 小時時，格式為 `(Xd Yh)`（X 為天數，Y 為剩餘小時）；24 小時以內維持現有格式不變。

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

#### Scenario: weekly quota 顯示（剩餘超過 1 天）
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在且含 `weekly_remaining` 與 `weekly_reset_at`，`weekly_reset_at` 距現在超過 24 小時
- **THEN** statusline 在 5h quota 之後包含 ` | 📊 N% (Xd Yh)`（X 為天數，Y 為剩餘小時）

#### Scenario: weekly quota 顯示（剩餘不足 1 天）
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在且含 `weekly_remaining` 與 `weekly_reset_at`，`weekly_reset_at` 距現在 1-24 小時
- **THEN** statusline 在 5h quota 之後包含 ` | 📊 N% (Xh Ym)`

#### Scenario: weekly quota 顯示（剩餘不足 1 小時）
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在且含 `weekly_remaining` 與 `weekly_reset_at`，`weekly_reset_at` 距現在不足 1 小時
- **THEN** statusline 在 5h quota 之後包含 ` | 📊 N% (Ym)`

#### Scenario: weekly quota 不存在（Lite 方案或舊快取）
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取存在但不含 `weekly_remaining` 欄位
- **THEN** statusline 不顯示 weekly quota 段，5h quota 顯示行為不變

#### Scenario: weekly reset 時間已過
- **WHEN** `CLAUDE_PROXY_MODE=glm`，快取含 `weekly_reset_at` 但已早於現在時間
- **THEN** weekly quota 顯示 ` | 📊 N%`，不顯示括號時間
