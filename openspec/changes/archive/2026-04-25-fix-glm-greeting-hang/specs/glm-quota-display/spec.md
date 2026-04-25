## MODIFIED Requirements

### Requirement: claude-glm 啟動時背景 fetch Z.ai quota 並快取
`claude-glm` SHALL 在啟動後以背景子程序呼叫 Z.ai quota API（`GET https://api.z.ai/api/monitor/usage/quota/limit`），使用 `GLM_API_KEY` 作為 Bearer token，並將結果解析後寫入 `/tmp/glm-quota-cache.json`。Fetch 失敗時 SHALL 靜默略過，不中斷啟動流程。

背景子程序 SHALL 以每 1 分鐘（60 秒）的間隔持續重新 fetch 並更新快取，直到 session 結束。單次 fetch 失敗時 SHALL 不中斷 loop，繼續等待下一個間隔。

背景子程序的 stdout 與 stderr SHALL 重定向至 `/dev/null`，確保不繼承 parent process 的 pipe 或 terminal file descriptors。此隔離防止在 command substitution（`$(...)`）等場景下，背景子程序持有 pipe write-end 導致 caller 永遠等不到 EOF。

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

#### Scenario: 定期更新
- **WHEN** `claude-glm` session 持續運行超過 1 分鐘
- **THEN** 背景子程序再次呼叫 API 並更新 `/tmp/glm-quota-cache.json`，`fetched_at` 欄位反映最新 fetch 時間

#### Scenario: API fetch 失敗
- **WHEN** `claude-glm` 啟動但 Z.ai API 呼叫失敗（網路錯誤、非 200 回應等）
- **THEN** `/tmp/glm-quota-cache.json` 不被修改，`claude-glm` 正常繼續啟動，不輸出錯誤至 stdout；背景 loop 繼續等待下一個間隔

#### Scenario: 無 TOKENS_LIMIT 資料
- **WHEN** API 回應不包含 `type=TOKENS_LIMIT` 的 limits 項目
- **THEN** `/tmp/glm-quota-cache.json` 不被修改，fetch 靜默略過

#### Scenario: command substitution 呼叫不會 hang
- **WHEN** `claude-glm --version` 在 command substitution 中被呼叫（例如 `result=$(claude-glm --version 2>&1)`）
- **THEN** command substitution 在 `claude --version` 輸出結果後正常返回，不會因為背景 quota loop 持有 pipe fd 而永久阻塞
