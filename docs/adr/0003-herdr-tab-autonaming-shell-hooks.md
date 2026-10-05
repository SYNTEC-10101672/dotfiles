---
status: accepted
---

# herdr tab 自動命名以 zsh hooks 自建

herdr 0.9.3 無原生的 automatic tab naming——config schema 與 runtime log 鑑識均證實現有 label 變更全來自手動改名。決定：以 zsh hooks 自建「自動命名」，集中於 herdr shell integration 檔 `herdr/shell.zsh`——preexec 把 tab 改名為指令第一個 word、precmd 回到 prompt 時改回 `shell`（`zsh`/`bash`/`sh` 一律 `shell`），改名經 `herdr tab rename "$HERDR_TAB_ID"`；檔頭以 `HERDR_TAB_ID` 守門，非 herdr 環境 source 後立即 return，`.zshrc` 僅一行 source 與區塊註解、不含任何 herdr 邏輯。

## Considered Options

- 輪詢 daemon（定期 `herdr pane process-info` 比對前景指令）：拒絕——可達完整 tmux `automatic-rename` 語意，但要養背景程序與 lifecycle 管理，成本不成比例。
- native workaround（`[ui] window_title` / sidebar `terminal_title` token）：拒絕——只改外層 terminal title 或 sidebar 顯示，不改 tab label，不合需求。

## Consequences

- 手動鎖定語意：hook 比對 `herdr tab get` 的 label 現值與自身記帳，非數字的不一致即視為手動改名，該 shell 停止改寫直到 tab 關閉（pane 的 shell 生命週期即鎖定生命週期）；herdr 新 tab 的預設數字 label 不觸發鎖定。
- 多 pane tab 的名稱由最後下指令的 pane 決定；鎖定僅對偵測到的該 pane shell 生效（grill 中明確接受的限制）。
- 依賴 jq 解析 `herdr tab get` 的 JSON（與 `alt+j`/`alt+k` 翻頁指令同依賴）。
- herdr 原生 automatic tab naming 落地後，`herdr/shell.zsh` 與 `.zshrc` 的 source 行整段可刪。
