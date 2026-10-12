---
status: accepted
---

# opencode v2 遷移：native permissions、guard.ts port、cheap explore/title model

ticket 04（simplify-harness 期間刻意 deferred 的 v2 backlog）在 v2 遷移啟動時一次執行：`opencode.json` 從 v1 `permission` block 改寫為 v2 ordered `permissions` array（`bash`→`shell` action；`**/.env` 系 pattern 改為 `*.env` 系——v2 的 `*` 已跨 `/`，`**` 會要求字面 `/` 而漏掉 repo root 的 `.env`；`*.env.example` 的 allow 排在 deny 之後，last match wins）；`guard.ts` port 成 v2 plugin API（`Plugin.define` default export、id `secret-guard`、`ctx.tool.hook("execute.before")`、`event.tool === "shell"`、`$` Bun shell 改 `node:child_process`）；`agents.explore.model` 與 `agents.title.model` 掛 `github-copilot/gpt-5.6-luna`（v1 `small_model` 角色的 v2 對應，auth 既有）；SDK 依賴 `@opencode-ai/plugin` → `@opencode/plugin`。binary 由 npm 的 `opencode-ai`（v1）改裝 `@opencode/cli`（v2）。

## Considered Options

- `permission` 與 `permissions` 雙寫過渡：拒絕——spec 已定調「v2 遷移一次寫對」，雙寫留下需再清理的 v1 殘骸，且 v1/v2 擇一生效的語意徒增困惑。
- guard.ts 改用 `ctx.permission.hook("evaluate")` 攔截：拒絕——語意不同（改寫 permission effect 而非讓 tool 執行失敗）；v1 行為是 tool error 帶指示訊息讓 agent 自行修正，`ctx.tool.hook("execute.before")` 是官方 migrate-v1 對照表的直接對應，throw 即阻斷。
- 保留 `**/.env` pattern 原文：拒絕——v2 wildcard `*` 本身跨 `/`，`**` 退化為「兩個連續萬用字元」、要求字面 `/` 存在，repo root 的 `.env`（主要標的）反而漏掉；`*.env` 系比 v1 略寬（連 `foo.env` 也 deny），但方向是 fail-closed，與 v2 內建 default policy 同型。

## Consequences

- `permissions` array 生效順序：read `*` allow → `*.env` / `*.env.*` / `*.credentials.json` deny → `*.env.example` allow（最後比對獲勝）→ shell `git push *` ask。Secret Guard 三層（read deny、commit 掃描、push 確認）行為不變。
- guard.ts 的 fail-closed 方針與三則錯誤訊息原文原樣保留；gitleaks 掃描的 color.ui=off env overlay 照舊。新增 `opencode/tests/guard.test.ts`（bun test：fake runner 單元測試 + 真 gitleaks integration，gitleaks 缺失時 skip）與 `opencode/tsconfig.json`（`npm run typecheck` = tsc --noEmit）；`tests/` 不隨 `make opencode` 部署。
- `ctx.tool.hook` event 本身無 cwd 資訊，而 v2 架構是單一 shared background service（v1 為 per-project server，`$` 的 cwd 就是 project）——gitleaks 掃描因此必須明確以 `ctx.location.directory`（plugin instance 的載入位置）為 cwd，否則會掃到 service cwd 而非 session project。此差異由 e2e 驗證發現並修正。
- matt 系列 commands/skills 檢查結果：frontmatter 無 `subtask`/`variant` 等 v1-only 欄位，v2 原樣支援；`agents/openai.yaml` 是 upstream 包裝的 Codex interface metadata，與 opencode 無關，不動。GLOSSARY 僅 Secret Guard 詞條需要改寫。
- v1 回溯相容完全放下：v1 binary 不認得 `permissions`、不載入 v2 plugin——升級 binary 前 Secret Guard 三層失效，故隨本 ADR 一併升級。回退路徑 = git history。
