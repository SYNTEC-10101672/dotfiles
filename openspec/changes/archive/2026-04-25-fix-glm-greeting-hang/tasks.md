## 1. 修正 background quota loop fd 洩漏

- [x] 1.1 在 `claude/scripts/claude-glm` 的 background subshell 加上 `> /dev/null 2>&1`，確保 stdout/stderr 不繼承 parent pipe fd
> 驗證：執行 `timeout 5 bash -c 'result=$(claude-glm --version 2>&1); echo "Got: $result"'`，應在 5 秒內輸出版本號而非 timeout（exit code 124）

## 2. 清理卡住的僵屍進程

- [x] 2.1 殺掉系統上卡住的 greeting-runner.sh 和 claude-glm --version 僵屍進程（PID 1933188、1933203、2039977、2039992、2124190、2124207 及其子進程）
> 驗證：執行 `ps aux | grep greeting-runner` 和 `ps aux | grep "claude-glm --version"`，應無殘留進程
