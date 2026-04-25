## Context

`claude-glm` script 在啟動時啟動一個背景 quota refresh loop（`(...)` + `&`），以 60 秒間隔 poll Z.ai API 並更新 `/tmp/glm-quota-cache.json`。此 loop 繼承 parent process 的所有 file descriptors，包含 stdin/stdout/stderr。

當 greeting-runner.sh 以 command substitution 呼叫 `claude-glm --version` 時（`VERSION=$(claude-glm --version 2>&1)`），建立的 pipe 的 write-end 被背景 loop 繼承。即使 `claude --version` 正常執行並退出，pipe 不會關閉（因為背景 loop 仍持有 write-end fd），導致 `$()` 永遠等不到 EOF。

## Goals / Non-Goals

**Goals:**
- 修正 background quota loop 的 fd 洩漏，使其不繼承 parent 的 stdout/stderr
- 清理系統上累積的卡住 greeting 進程

**Non-Goals:**
- 更改 quota refresh loop 的功能邏輯或間隔
- 修改 greeting-runner.sh 的邏輯

## Decisions

### 1. 在 background loop 加 output redirect 而非修改 greeting-runner.sh

**選擇**：在 `claude-glm` 的 background subshell 加上 `> /dev/null 2>&1`

**理由**：fd 洩漏是 `claude-glm` 的問題，應該在來源修正。任何透過 pipe 呼叫 `claude-glm` 的場景（不只是 greeting）都可能遇到相同的 hang 問題。修改 greeting-runner.sh 只能治標。

**替代方案**：
- greeting-runner.sh 用 temp file 取代 `$()`：治標不治本，其他呼叫方仍有風險
- claude-glm 偵測 `$()` 環境並 skip background loop：不可靠，且 `--version` 等非互動呼叫也會需要 quota display

### 2. 清理方式：手動 kill 僵屍進程

卡住的進程（greeting-runner + claude-glm --version + background sleep）需要手動清理，因為這是一次性問題。

## Risks / Trade-offs

- [Background loop 錯誤輸出被吞掉] → 現有設計已將 curl stderr 導向 `/dev/null`（`2>/dev/null`），加 `> /dev/null 2>&1` 只影響潛在的 debug 輸出，不影響功能
- [多個 claude-glm session 的 quota cache 寫入競爭] → 已有問題，非本 change 引入，不在此處處理
