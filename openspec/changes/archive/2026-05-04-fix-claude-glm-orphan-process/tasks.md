## 測試

- [x] T1 驗證 Ctrl+C 後無殘留 process（手動驗證）
  > 指令：啟動 claude-glm，立即按 Ctrl+C，執行 `ps aux | grep claude-glm | grep -v grep` 確認無殘留
  > 預期：無任何 claude-glm bash process 殘留

- [x] T2 驗證 quota 背景功能正常運作（手動驗證）
  > 指令：啟動 claude-glm，等待 5 秒後檢查 `/tmp/glm-quota-cache.json` 是否存在且有 `fetched_at` 欄位
  > 預期：快取檔案存在且內容正確

- [x] T3 驗證正常退出（/exit）無殘留（手動驗證）
  > 指令：啟動 claude-glm，輸入 `/exit`，執行 `ps aux | grep claude-glm | grep -v grep`
  > 預期：無殘留 process

- [x] T4 驗證 command substitution 不 hang（手動驗證）
  > 指令：執行 `result=$(timeout 10 ~/bin/claude-glm --version 2>&1)` 並 echo $?
  > 預期：command 在 10 秒內返回，exit code 為 0

## 實作

- [x] 1.1 修改 `~/bin/claude-glm`：將 background subshell 的 PID 存入變數，並在啟動 claude 前註冊 `trap ... EXIT INT TERM` 清理函數（→ T1, T2, T3）
- [x] 1.2 修改 `~/bin/claude-glm`：將 `exec claude "$@"` 改為 `claude "$@"`（→ T1, T3, T4）
