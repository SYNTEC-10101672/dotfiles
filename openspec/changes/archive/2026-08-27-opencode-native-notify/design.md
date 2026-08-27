# Design: opencode-native-notify

## Context

現行 tmux 通知鏈路（Claude Code 端）：

```
~/.claude/settings.json hooks（Stop / Notification / PreToolUse AskUserQuestion）
  → claude/scripts/claude-notify-{stop,waiting}.sh
  → tmux @claude_state + BEL → .tmux.conf:148 status bar 顯示 ✓ / ?
```

opencode 端現況：oh-my-openagent 的 `claude-code-hooks` 子系統（bridge）讀同一份 `settings.json`，把 Claude Code hook 協議模擬到 opencode plugin events 上執行。使用者已確認：只需完成 bell 與 waiting bell，atuin 記錄不需要。

關鍵事實（調查確認）：

- 兩支 notify scripts **不讀 stdin JSON**，只靠 `$TMUX` / `$TMUX_PANE` 環境變數做事 — 移植零改動
- opencode native plugin 機制：`~/.config/opencode/plugins/*.ts` 自動載入（不需登記於 `opencode.json` 的 plugin 陣列）；SDK `@opencode-ai/plugin` 實際安裝於 `~/.config/opencode/node_modules/` 為 **1.14.19**（`dotfiles/opencode/package.json` 宣告 1.4.11，與實際安裝已漂移 — 本次僅依賴存在性，不處理版號對齊）
- 事件對應：Claude `Stop` → opencode `session.idle`；Claude `Notification(permission_prompt)` / `PreToolUse(AskUserQuestion)` → opencode `permission.asked`
- oh-my-openagent 偵測到外部通知 plugin 時會 auto-disable 內建通知（原始碼 `getNotificationConflictWarning`），但偵測對象為 npm 套件，本地 plugin 是否觸發待驗證
- 背景 agent（explore/librarian 等）是 child session，`client.session.get()` 回傳的 session 物件含 `parentID` 欄位可判斷主從

## Goals / Non-Goals

**Goals:**
- 完成（主 session idle）→ `notify-stop.sh`：tmux `@claude_state=done`（✓）+ BEL
- 等待（permission 詢問）→ `notify-waiting.sh`：tmux `@claude_state=waiting`（?）+ BEL
- 背景 agent 的 idle 不觸發 bell
- 通知機制與 `claude/` 目錄、`settings.json` 完全解耦（新檔案，非 symlink）
- 停用 bridge 後 oh-my-openagent 其餘功能（agents / model routing）不受影響

**Non-Goals:**
- 不移植 atuin shell 歷史記錄（已確認不需要）
- 不刪除 `claude/settings.json` hooks 或 `claude/scripts/`（另案：claude 設定檔清理）
- 不處理 `settings.json` 的 `permissions` 對應（opencode 有自己的 permission 設定，另行處理）
- 不做 double-bell debounce（除非實測出現重複，先不做不可能場景的處理）

## Decisions

### D1: 一支本地 plugin 檔，不用 npm package

`dotfiles/opencode/plugins/notify.ts` 單檔，透過 symlink 部署到 `~/.config/opencode/plugins/`。相較 npm package：零建置、零版本管理負擔，且 oh-my-openagent 的 auto-disable 偵測不到也不影響（見 D4）。

### D2: 主 session 判斷用 `parentID`

`session.idle` 事件觸發時，以 `client.session.get({ id: sessionID })` 查 session，`parentID` 為空 = 主 session 才通知。替代方案（比對 agent 名稱清單）脆弱 — 新增 agent 就要維護清單。**驗證點**：`parentID` 欄位語義需實測確認，不成立時 fallback 為「session 事件 properties 內建的 parent 資訊」。

### D3: scripts 為獨立新檔，內容複製不改寫

`notify-stop.sh` / `notify-waiting.sh` 內容照抄 `claude-notify-*.sh`（只靠 tmux 環境變數，無 Claude 耦合）。不改為 symlink：後續 claude 設定檔刪除議題進行時，兩邊可獨立演化。**注意**：`$TMUX_PANE` 在 plugin spawn 的子 process 中是否存在需驗證 — plugin 由 opencode server process 載入，server 若繼承 tmux 環境則可用；不可用時改由 script 接收 pane target 參數。

### D4: 關 bridge（`claude_code.hooks: false`）而非依賴 auto-disable

明確設定 `"hooks": false` 關閉 bridge，不依赖 oh-my-openagent 偵測外部 plugin 的 auto-disable 行為（其偵測對象為 npm 套件，本地 plugin 未必觸發）。內建通知系統（desktop notification）與本 plugin 的 double bell 風險靠實測驗收，若衝突再以 `notification.force_enable` 或反向配置處理。

### D5: `permission.asked` 涵蓋 permission 語義；question tool 走 `tool.execute.before`

Claude 端 waiting 由兩個事件觸發（`Notification(permission_prompt)` + `PreToolUse(AskUserQuestion)`）。實證（opencode 1.18.22）：permission dialog 觸發 `permission.asked`（SDK 1.14.19 type union 落後未收錄，binary 實際 emit）；**question tool 不觸發 `permission.asked`** — 問答 UI 走獨立的 `tool.execute.before`（tool=question）路徑補齊，對齊 Claude 端 `PreToolUse(AskUserQuestion)` 語義。elicitation 類對話（MCP 向使用者要資訊）若不觸發 `permission.asked` 則少通知 — 已評估可接受。

Watch-item（review 記錄，未實作）：`permission.asked` 未做 parentID 過濾（與 `session.idle` 不對稱）— 背景 agent 若觸發 permission 詢問，會在主 window 設 waiting。當前背景 agent 配置下 headless 自動 allow，場景罕见；若日常使用觀察到誤響再補過濾。

### D6: SDK client 回傳為 `{ data }` 包裝

`client.session.get()` 回傳 `{ data: Session, request, response }`（tsc 實證），parentID 過濾須存取 `result.data?.parentID`。`session.idle` 的 payload shape 跨版本變動，sessionID 以 `props.sessionID ?? props.session?.id ?? props.info?.id` 防禦式取得（live 實證可用）。

## Risks / Trade-offs

- [`$TMUX_PANE` 在 plugin 環境可能為空] → 驗證任務 T3 先確認；fallback：plugin 透過 `client` 取得 session 的 tty 資訊傳參給 script
- [`session.idle` 可能在一輪內多次觸發（如 permission 回覆後）] → 實測 T4 驗證；出現重複 bell 才加 debounce，不預做
- [oh-my-openagent 內建通知與本 plugin double bell] → 實測 T5；衝突時關內建（設定存在但 auto-disable 對本地 plugin 未必生效）
- [`parentID` 語義與假設不符] → T1 以背景 agent 實測；fallback 見 D2
- [oh-my-openagent 升級改變 hook 開關語義] → `"hooks": false` 是其公開 schema 的一級欄位（`oh-my-opencode.schema.json` `properties.claude_code.properties.hooks`），屬穩定介面

## Migration Plan

1. 新增檔案（plugins / scripts）→ 2. `make opencode` 部署 → 3. 改 `oh-my-openagent.json` 關 bridge（4.6 的 atuin 檢查需要 bridge 已關，故先關再測）→ 4. 實測驗證（T1-T6）→ 5. 更新 README
6. Rollback：還原 `oh-my-openagent.json`（移除 `"hooks": false`）+ 移除 `~/.config/opencode/plugins/notify.ts` 即回到現況

## Open Questions

- 無（決策皆已收斂；待驗證項目已列入 tasks 的 T*）
