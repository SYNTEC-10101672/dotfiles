## Context

`claude-glm` 啟動時以背景 subshell 呼叫 Z.ai quota API 並將結果寫入 `/tmp/glm-quota-cache.json`，`claude-code-statusline` 讀取此檔案顯示 quota。目前背景 subshell 只執行一次 fetch 就結束，導致整個 session 期間 quota 數字不更新。

## Goals / Non-Goals

**Goals:**
- session 期間定期更新 quota cache，使 statusline 顯示的數字接近真實值
- 改動範圍最小化（只改 `claude-glm`，statusline 不動）

**Non-Goals:**
- 調整 poll 間隔（固定 3 分鐘）
- session 結束時清理背景 process（下次啟動會自然覆寫 cache，舊 process 退出後無副作用）

## Decisions

### 決策 1：使用 while/sleep loop 取代單次 fetch

將背景 subshell 從單次 `curl → write` 改為 `while true; do curl → write; sleep 180; done`。

**考慮的替代方案：**
- **statusline 自行判斷 cache 年齡並 fetch**：statusline 觸發頻率高（每次 tool use），在 statusline 裡打 API 會阻塞 UI。捨棄。
- **使用 systemd timer 或 cron**：過度工程化，且需要使用者額外設定。捨棄。

採用 while/sleep loop，簡單且只改一個檔案。

### 決策 2：不處理 session 結束時的背景 process 清理

`exec claude` 取代當前 shell 後，背景 subshell 變成 orphan process。它會持續 sleep + fetch 直到 `claude-glm`（即 `claude`）結束後仍可能再跑一兩輪。

**不清理的理由：**
- 資源消耗極低（sleep 佔 ~0% CPU）
- 舊 process 最終會寫入一次 cache 後再 sleep 180 秒，之後無新的 API 呼叫產生，不會造成問題
- 加入 trap 或 PID 追蹤增加複雜度，收益不成比例

## Risks / Trade-offs

- **Orphan process 殘留**：`claude-glm` 退出後背景 loop 可能再多跑 1-2 輪。→ 影響極小，無需處理。
- **多實例並行寫入**：若同時開多個 `claude-glm`，多個背景 loop 會並行寫入同一個 cache。→ last-write-wins，資料內容相近，不影響正確性。
