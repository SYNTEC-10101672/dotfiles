# Design: add-commit-gate-plugin

## Context

- ultrawork（`/opsx:apply ulw`）的 COMMIT DISCIPLINE 要求模型每個 verified increment 就 commit，AI 自發 commit 無法以現有機制選擇性阻擋
- `opencode/plugins/guard.ts` 已驗證 `tool.execute.before` + `throw` 的攔截模式（gitleaks staged 掃描）：hook 在 permission check 前觸發，throw 後模型收到 tool error、session 繼續
- 已對實裝 SDK（`@opencode-ai/plugin` 1.14.19，`~/.config/opencode/node_modules`）驗證：
  - `command.execute.before`：`input = { command, sessionID, arguments }`
  - `tool.execute.before`：`input = { tool, sessionID, callID }`、`output = { args }`
  - `event` hook 收 `session.deleted` / `session.idle`（型別見 `@opencode-ai/sdk` `types.gen.d.ts`）
  - `permission.ask` hook 型別存在但 permission evaluator 未觸發它 — 不可作為攔截點
- local plugins 由 `{plugin,plugins}/*.{ts,js}` glob auto-discovery 載入（`guard.ts`、`notify.ts` 皆未註冊於 `opencode.json` 的 `plugin` array）
- 使用者流程：ulw 完成後人工確認，經 `/commit`（多輪互動，Phase 4 才執行 commit）下 commit，事後清 session

## Goals / Non-Goals

**Goals:**

- 未授權 session：AI 的 `git commit` 一律阻擋，且模型收到訊息後不重試、繼續當前任務
- authorized session（執行過 `/commit` 的 session）：`git commit` 放行
- subagent（獨立 `sessionID`）一律阻擋，不做繼承

**Non-Goals:**

- `git push` 行為（維持 `opencode.json` 的 `"ask"`）
- git plumbing（`commit-tree`、`update-ref`）、`--continue` 家族、script 內藏 commit 的偵測（對抗性繞路，靠錯誤訊息聲明禁止）
- 修改 `opencode.json`、`guard.ts`、`commit.md`
- 授權 TTL 或跨 session 繼承

## Decisions

### D1：攔截點 = `tool.execute.before` + `throw`

- vs `permission.ask`：evaluator 未觸發（見 Context），不可靠
- vs permission config `"git commit *": "deny"`：deny 是 final，無授權通道；`ask` 在 unattended ulw 會卡住任務
- `tool.execute.before` 在 permission check 前觸發，throw 即 block，模型收到 error 可續行 — `guard.ts` 已在 production 驗證同模式

### D2：授權通道 = `command.execute.before` 的 `input.command`

`input.command` normalize 前導 `/` 後等於 `"commit"` → 授權該 `sessionID`；任何其他 command → 清除。

- vs `chat.message` 掃訊息文字：command 內容會改版，比對特徵字串脆弱；`command` 名稱是穩定 API
- vs 在 `commit.md` 加 marker 字串：需改 command 檔案，且 marker 對模型可見、有 replay 面
- `input.command` 的實際值（`"commit"` 或其他形式）實作時以 log 驗證一次；normalize 只處理前導 `/`

### D3：授權生命週期 = `Map<sessionID, true>`，事件清除，無 TTL

- 授權：`command.execute.before` 命中 `/commit`
- 清除：任何非 `/commit` command；`session.deleted` event
- **不監聽 `session.idle`**：`/commit` 是多輪互動流程，idle 發生在每個 phase 之間，若在 idle 清除會擋到 Phase 4 的實際 commit（設計陷阱，明記）
- 殘留風險（接受）：`/commit` 後未清 session、又以純文字（非 slash command）觸發 ulw → 授權仍在；後果等同改動前行為，使用者習慣 commit 後清 session
- 不做 subagent 繼承：ulw 的 commit 壓力恰恰下發給 subagent（主戰場）；`/commit` 流程不經過 subagent，繼承無受益者

### D4：偵測 regex

```
/\bgit\s+(?:-\S+\s+(?:\S+\s+)?)*commit(?![\w-])/
```

- `git commit -m "x"` ✓（零 flag）
- `git -C /path commit`、`git -c user.name=x commit` ✓（flag + 可選值，可重複）
- `git add . && git commit -m x` ✓、`GIT_EDITOR=true git commit` ✓（unanchored，子字串即命中）
- `git commit-tree` ✗（`(?![\w-])` 排除）、`git rebase --continue` ✗（僅匹配 `commit` subcommand）
- vs `guard.ts` 的 `includes("git commit")`：漏 `-C` 與 env prefix 形狀；guard 漏抓後果是少掃一次，本 gate 漏抓後果是 commit 直接執行，標準不同
- 已知誤擋：指令字串中引用 "git commit" 文字（如 `echo "git commit"`）→ 可接受，模型讀錯誤訊息後改寫即可

### D5：阻擋訊息（英文，與 `guard.ts` 一致）

訊息必須命中 ulw COMMIT DISCIPLINE 的 skip 條件原文（"Skip only when the user forbade commits this session"），讓模型不需推理即知可合法跳過：

```
git commit blocked by user policy: AI must not run git commit.
The user has forbidden commits this session — per COMMIT DISCIPLINE
("Skip only when the user forbade commits this session"), skip
committing and continue completing the current task. Leave changes
uncommitted; the user will commit manually via /commit.
Do not retry or work around.
```

### D6：與 Secret Guard 分層

兩個 plugin 同掛 `tool.execute.before`：未授權 → 本 plugin throw（指令不執行）；已授權 → 本 plugin 放行，`guard.ts` 續掃 gitleaks。任一 throw 即 block，plugin 載入順序無關。`opencode-secret-guard` 的 requirements 不變。

### D7：測試位置 = `opencode/test/commit-gate.test.ts`

- 不可放 `opencode/plugins/`：`{plugin,plugins}/*.{ts,js}` glob 會把 `.test.ts` 當 plugin 載入
- `opencode/test/` 不在 Makefile `opencode` target 的 deploy 清單（只 symlink commands/skills/AGENTS.md/opencode.json/package.json/omo.jsonc/plugins/scripts），repo-local 不部署
- `import type { Plugin }` 在 transpile 時擦除，`bun test` 不需 runtime 解析 `@opencode-ai/plugin`
- 以 bun 內建 test runner（環境已有 bun 1.3.13），不引入新依賴

## Risks / Trade-offs

- [`command.execute.before` 的 `command` 值形式未經 runtime 驗證] → 實作第一步先 log 真實值再定 normalize；比對以第一個 token 為準
- [指令字串含 "git commit" 文字被誤擋] → 錯擋後果是模型改寫指令，不影響正確性；錯誤訊息說明原因
- [授權殘留（純文字觸發 ulw）] → 接受；後果等同改動前行為，且使用者慣於 commit 後清 session
- [opencode server 重啟中斷 `/commit` 流程] → state 為 in-memory，重啟後授權消失，重跑 `/commit` 即可
- [SDK 版本不一致（`package.json` 1.16.2 vs 實裝 1.14.19）] → hooks 已對實裝版本驗證存在；版本更新另行處理，不屬本 change

## Migration Plan

- 檔案寫入即部署：`opencode/plugins/` 已整目錄 symlink 至 `~/.config/opencode/plugins`，auto-discovery 於下次 opencode 啟動載入
- 回滾：刪除 `opencode/plugins/commit-gate.ts` 與 `opencode/test/commit-gate.test.ts`，還原 `README.md` 一行

## Open Questions

（無 — 邊界決策已於 explore/grill 階段全數定案）
