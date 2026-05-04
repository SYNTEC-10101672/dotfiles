## Why

`claude-glm` 啟動腳本在 background 跑了一個 quota fetch loop（每 60 秒 curl Z.ai API），但因為使用 `exec claude` 將 bash process 替換成 claude，導致沒有 parent process 負責在退出時清理該 background process。每次 Ctrl+C 關掉 claude-glm，quota fetch subshell 就變成孤兒 process 殘留在背景，持續消耗資源。

## What Changes

- 修改 `~/bin/claude-glm` 腳本：移除 `exec`，改為一般執行 `claude "$@"`，並加入 `trap` 在收到 EXIT/INT/TERM signal 時殺掉 background quota fetch process
- 背景子程序改用 disown + 記錄 PID 的方式，確保 trap 能可靠清理

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `glm-quota-display`: 新增「背景子程序生命週期與清理」行為要求——背景 quota fetch subshell SHALL 在 claude-glm 退出時被終止，不殘留孤兒 process

## Impact

- `~/bin/claude-glm` 腳本邏輯變更（此檔案不在 dotfiles repo 內，是手動部署到 `~/bin/` 的）
- 不影響 GLM quota 快取格式、statusline 顯示、tmux window rename 等既有功能
