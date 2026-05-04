## MODIFIED Requirements

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

`claude-glm` 腳本 SHALL 在啟動背景子程序時記錄其 PID，並透過 `trap ... EXIT INT TERM` 註冊清理函數，確保在腳本退出時（無論是正常退出、Ctrl+C、或收到 TERM signal）殺掉背景子程序。`claude` SHALL 以一般呼叫（非 `exec`）方式啟動，使 bash process 在 claude 退出後仍存在以執行清理。

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

#### Scenario: Ctrl+C 退出時清理背景子程序
- **WHEN** 使用者在 claude-glm 運行中按下 Ctrl+C
- **THEN** claude 正常退出，bash 執行 EXIT trap 殺掉背景 quota fetch 子程序，不留殘留 process

#### Scenario: 正常退出時清理背景子程序
- **WHEN** 使用者在 claude 中輸入 `/exit` 或 claude 自行結束
- **THEN** bash 執行 EXIT trap 殺掉背景 quota fetch 子程序，不留殘留 process

#### Scenario: 收到 TERM signal 時清理背景子程序
- **WHEN** `claude-glm` 的 bash process 收到 SIGTERM
- **THEN** bash 執行 TERM trap 殺掉背景 quota fetch 子程序，不留殘留 process
