## 1. 修改 quota refresh 間隔

- [x] 1.1 將 `claude/scripts/claude-glm` 中兩個 `sleep 180` 改為 `sleep 60`

> 驗證：執行 `grep 'sleep' claude/scripts/claude-glm`，輸出應包含兩個 `sleep 60`，不含 `sleep 180`
