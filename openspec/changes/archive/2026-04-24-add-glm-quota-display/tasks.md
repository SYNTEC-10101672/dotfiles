## 1. claude-glm：背景 fetch 並快取 quota

- [x] 1.1 在 `claude-glm` 結尾新增背景子程序：呼叫 Z.ai quota API，解析 TOKENS_LIMIT，將 `tokens_remaining`、`tokens_reset_at`、`fetched_at` 寫入 `/tmp/glm-quota-cache.json`

> 驗證：啟動 `claude-glm --version` 後約 2 秒內，`cat /tmp/glm-quota-cache.json` 應輸出含三個欄位的 JSON；API 失敗時（如拔掉網路）不應有任何錯誤訊息出現在 terminal

## 2. claude-code-statusline：GLM 模式讀取 cache 並顯示

- [x] 2.1 在 `claude-code-statusline` 的 GLM mode 分支新增：讀取 `/tmp/glm-quota-cache.json`，計算 reset 倒數，產生 `| 🔋 N% (Xh Ym)` 或 `| 🔋 N% (Ym)` 或 `| 🔋 N%` 格式並附加至輸出

> 驗證：有 cache 且 reset 未到時，執行 `echo '{"model":{"display_name":"glm-5-turbo"},"workspace":{"current_dir":"/tmp"},"context_window":{}}' | CLAUDE_PROXY_MODE=glm ~/.claude/scripts/claude-code-statusline` 輸出應包含 `🔋` 及百分比與倒數時間；cache 不存在時輸出不含 `🔋`
