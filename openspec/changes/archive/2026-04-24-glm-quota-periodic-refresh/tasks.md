## 1. claude-glm：定期更新 quota cache

- [x] 1.1 將背景 subshell 從單次 fetch 改為 `while true; do ...; sleep 180; done` loop，確保 session 期間每 3 分鐘更新一次 `/tmp/glm-quota-cache.json`

> 驗證：啟動 `claude-glm --version` 後執行 `watch -n 1 'cat /tmp/glm-quota-cache.json | jq .fetched_at'`，觀察 `fetched_at` 約每 180 秒更新一次
