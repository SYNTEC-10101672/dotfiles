---
status: accepted
---

# 重新採用 @slkiser/opencode-quota（supersede ADR-0007 的 quota 條款）

ADR-0007 退役 `@slkiser/opencode-quota` 的理由是 v1/v2 plugin 斷代（v1 plugin implementation 不在 v2 執行）。前提已反轉：5.x 原生支援 OpenCode 2，init 精靈有 symlink-resolve 機制（偵測到 `opencode.json` 為 symlink 時走 realpath 原地編輯 repo 檔，部署鏈不被破壞），退役理由消失。重新採用並 pin exact 版號 `@slkiser/opencode-quota@5.0.2`：此 plugin 能讀 OpenCode logins（Z.ai api key source = `opencode.db`），供應鏈信任等級等同 model provider 連線，pin exact 與 Secret Guard 的防護精神及 vendor 基準線的可審視性一致；installer 一律寫 `@latest`，故 repo `opencode.json` 手動改為 exact pin。顯示面收斂為一行 compact status line（`formatStyle: "allWindows"`——`singleWindow` 自動挑剩餘 % 最低的 window，週上限不保證出現；Home 底部一行、session prompt / toast / sidebar / prompt bar 全關，`/quota` 保留全文報告）。設定檔 `opencode-quota/quota-toast.jsonc` 進 repo opencode 模組，以單檔 symlink deploy：`~/.config/opencode/opencode-quota/` 目錄本體留實體——該目錄未來可能放其他 provider 的 secret 檔（如 xiaomi/mimo 的 `mimo.json`），整目錄 link 總有一天把 secret 掃進 repo。`waitForQuotaReset` 維持開（plugin default）：request 撞上 provider 上限時等待該 quota window reset，而非 OpenCode 平常的 retry timing——代價是該 request 可能掛起數小時，換取上限時不對付費 API 撞牆。本 ADR 僅 supersede ADR-0007 的 quota plugin 退役條款；OmO 維持 retired，ADR-0007 其餘決策不變。

## Considered Options

- bare specifier（`@slkiser/opencode-quota` 或 `@latest`）：拒絕——可讀 OpenCode logins 的 plugin 每次啟動都可能拉進維護者未審視的新版；exact pin 讓升級成為 repo diff 上的顯式決策。
- 整目錄 symlink（`opencode-quota/` 直接 link 進 `~/.config/opencode/`）：拒絕——部署較省一行，但目錄內未來出現 secret 檔（copilot token、mimo cookie）時會被掃進 repo；單檔 link 的粒度把 secret 隔絕在 repo 邊界外。
- `waitForQuotaReset: false`（撞上限即快速失敗）：拒絕——長 session 撞 Z.ai 週上限時，掛起至 reset（最長約兩天）優於中斷工作流；個人使用情境可接受。
- 維持 retired、用 `/quota_status` 裸 tool：拒絕——`/quota_status` 是診斷 dump，不顯示常駐剩餘量；週上限可見性（本決策的起點）無法滿足。

## Consequences

- `opencode.json` 的 `plugin` array 帶 `@slkiser/opencode-quota@5.0.2`；升級 = `npm view @slkiser/opencode-quota version` 後改 pin 並重啟，回退路徑 = 移除 plugin entry（git history）。
- Makefile 的 opencode target 增加單檔 symlink（含 `mkdir -p` 與實體檔 guard），`check` / `uninstall` 一併覆蓋；`opencode/tests/quota-plugin.test.ts` 守 exact-pin 與顯示共識不變量。
- init 精靈重跑時：`configFormat` 選 `json`（原地編輯 realpath）；選 `jsonc` 會嘗試 `opencode.json` → `opencode.jsonc` 轉換並因 symlink source 拒絕。
- request 撞上 provider 上限時掛起至 window reset（`waitForQuotaReset` 開的代價，最長約一個 window 週期）。
- ADR-0007 標記 partially superseded（僅 quota 條款）；OmO 退役與 ADR-0007 其餘內容不變。

## 修訂（2026-10-13）

- 顯示面從「僅 Home 底部」改為「Home 底部 + 每個 session prompt 底下」（`tuiCompactStatus.sessionPrompt: true`）：Home-only 決策修訂，日常工作多在 session 內，離開 Home 就看不到剩餘量違背本 ADR 的目的。
- `enabledProviders` 從 `"auto"` 收斂為 `["zai"]`：Copilot 為無上限方案，quota 資訊量為零（compact line 與 `/quota` 都不再顯示）；未來加入計量 provider 時擴充此 list。
