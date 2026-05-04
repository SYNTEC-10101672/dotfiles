## Context

`~/bin/claude-glm` 是一個 bash wrapper 腳本，負責設定 GLM API 環境變數、啟動 quota background fetcher、rename tmux window，最後用 `exec claude "$@"` 啟動 Claude Code CLI。

目前腳本在第 65-89 行用 `( ) &` 啟動一個 background subshell 跑 quota fetch loop，之後第 92 行用 `exec` 將 bash process 替換為 claude。這導致 bash 不再存在，無人負責清理 background subshell。

## Goals / Non-Goals

**Goals:**
- claude-glm 退出時（Ctrl+C、正常退出、或異常終止）background quota fetch process 必須被清理
- 保持所有既有功能不變（quota 快取、statusline 顯示、tmux rename）
- 修正方式盡量簡潔，不引入額外依賴

**Non-Goals:**
- 不修改 quota fetch 的邏輯或快取格式
- 不修改 statusline 或 tmux rename 行為
- 不將 `~/bin/claude-glm` 納入 dotfiles repo 管理（維持現狀，手動部署）

## Decisions

### D1: 移除 exec，改用 trap 清理

**選擇**：將 `exec claude "$@"` 改為 `claude "$@"`，並在 background subshell 啟動後用 `trap ... EXIT INT TERM` 註冊清理函數。

**替代方案**：
- 在 exec 前寫 PID 到 `/tmp` 檔案讓外部清理 → 不可靠，需要額外機制觸發
- 用 process group (`setsid`) + kill 整個 group → 過度複雜，可能影響 claude 自身的 signal 處理

**理由**：不用 exec 意味著多一層 bash process，但 overhead 可忽略。trap 是 bash 內建機制，可靠且簡潔。`claude "$@"` 結束後 bash 自動執行 EXIT trap，即使 claude 被 SIGINT 殺掉也能觸發。

### D2: trap 涵蓋 EXIT、INT、TERM 三個 signal

`EXIT` 覆蓋正常退出和 bash 收到 signal 後的清理，`INT` 和 `TERM` 確保 bash 在 claude 被外部 signal 終止前有機會執行清理。

## Risks / Trade-offs

- **多一層 bash process** → Memory overhead 約幾 MB，可忽略
- **signal 傳遞** → `claude` 不再是 PID 1（從 shell 的角度），但 bash 預設會將 foreground process 放在 terminal 的 controlling process group，Ctrl+C 仍會送到 claude
