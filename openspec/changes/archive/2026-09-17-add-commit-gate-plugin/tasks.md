# Tasks: add-commit-gate-plugin

## 1. Tests（Red — 先寫失敗測試）

- [x] 1.1 建立 `opencode/test/commit-gate.test.ts`（bun test 內建 runner，`import type { Plugin }` 型別匯入；測試直接呼叫 plugin 回傳的 hooks，以假 `sessionID` 模擬事件序列）。測試命名以群組前綴 `detect:` / `message:` / `lifecycle:` 分類，對應 T1–T3。此時 `opencode/plugins/commit-gate.ts` 尚不存在，T1–T3 全數 fail（Cannot find module）→ T*

## 2. Implementation（Green — 最小實作翻綠）

- [x] 2.1 實作 `opencode/plugins/commit-gate.ts`：export `CommitGatePlugin: Plugin`，結構比照 `opencode/plugins/guard.ts`（`declare const process` 不需要 — 本 plugin 不用 `$`）。三個 hook：
  - `command.execute.before`：`input.command` 去除前導 `/` 後 `=== "commit"` → `authorized.set(sessionID, true)`；否則 `authorized.delete(sessionID)`（Map 為 plugin 閉包內 state）
  - `tool.execute.before`：`input.tool !== "bash"` return；`output.args.command` 匹配 design.md D4 regex 且 `!authorized.has(sessionID)` → `throw new Error(D5 訊息全文)`
  - `event`：`event.type === "session.deleted"` → `authorized.delete(event.properties.sessionID)`
  - 阻擋訊息全文照 design.md D5，一字不改 → T1, T2, T3

## 3. Docs 與 Manual QA

- [x] 3.1 更新 `README.md` 專案結構段落 `opencode/plugins/` 的括號描述：加入 `commit-gate.ts：AI git commit 授權閘（未授權 session 一律擋，/commit 授權放行）`，與既有 `guard.ts`、`notify.ts` 描述並列
- [x] 3.2 Manual QA（真實 surface，豁免 T* 自動化 — 需真實 opencode session 與模型互動，無法以 shell command 重現）：
  1. 重啟 opencode TUI（讓 auto-discovery 載入新 plugin）
  2. 任意 session 要求模型 `git commit` → 觀察：被擋、錯誤訊息出現、模型未中斷繼續回覆
  3. 執行 `/commit` 走完 Phase 4 → 觀察：commit 成功執行
  4. 同 session 再要求模型 `git commit`（此時已無新授權）→ 觀察：被擋
  5. 順手以 `/commit` 觸發一次 `command.execute.before` log，確認 `input.command` 實際值與 normalize 假設相符（design.md D2 驗證點）

## Tests

- [x] T1: 偵測範圍 — 四種 `git commit` 形狀被擋、plumbing 與 `--continue` 放行
  > Command: `cd /home/syntec/personal/dotfiles && bun test opencode/test/commit-gate.test.ts -t "detect:"`
  > Expected: exit code 0，filter 內全數 pass（含 `git commit -m`、`git -C <path> commit`、`git add . && git commit`、`GIT_EDITOR=true git commit` 被擋；`git commit-tree`、`git rebase --continue` 不擋）

- [x] T2: 阻擋訊息要素 — 命中 COMMIT DISCIPLINE skip 條件、指示續作、禁止繞路
  > Command: `cd /home/syntec/personal/dotfiles && bun test opencode/test/commit-gate.test.ts -t "message:"`
  > Expected: exit code 0，thrown Error message 同時含 "forbidden commits this session"、"continue completing"、"/commit"、"Do not retry or work around"

- [x] T3: 授權生命週期 — `/commit` 授權放行、subagent 不繼承、其他 command 清除、`session.deleted` 清理、非 commit 指令不受影響
  > Command: `cd /home/syntec/personal/dotfiles && bun test opencode/test/commit-gate.test.ts -t "lifecycle:"`
  > Expected: exit code 0，filter 內全數 pass（`command: "commit"` 後同 sessionID 放行；不同 sessionID 擋；`command: "eli5"` 後擋；`session.deleted` event 後擋；`git status` / `git add .` 不觸發阻擋）
