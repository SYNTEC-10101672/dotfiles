---
status: partially superseded by 0010-readopt-opencode-quota-plugin.md (quota plugin clause only; OmO stays retired)
---

# OmO 與 quota plugin 退役，harness 回歸純 opencode core

oh-my-openagent（OmO）是 opencode 之上的 agent/category model 排程層：為 oracle/explore/librarian 等 agent 名冊與 cheap-model 排程分配 model，日常使用率極低，維護成本卻是每天載入的 plugin、`~/.omo/omo.jsonc` 部署鏈與文件負擔。`@slkiser/opencode-quota` 只服務 quota toast 顯示。決定兩者退役，harness 收斂為純 opencode core：`opencode.json` 僅剩 `$schema` + `permission` + top-level `model`（`zai-coding-plan/glm-5.3`）——top-level `model` 是唯一原樣存活 opencode v2 的寫法，`permission` 的 v2 改寫（`permissions` array）另見 migration backlog。退役動機之一是 v2 plugin 斷代：v1 plugin implementation 不在 v2 執行（官方 migrate-v1 guide 明文），這兩個 v1 npm plugin 在 v2 都是死路，先拆先省。

## Considered Options

- 等到 v2 遷移時一併處理：拒絕——兩個 plugin 與 `~/.omo` 部署鏈此刻就是維護負擔，且 v1 npm plugin 在 v2 反正不執行，提前退役零損失。
- 保留 quota plugin、只退役 OmO：拒絕——quota plugin 同為 v1 npm plugin，v2 死路一條；quota toast 是 nice-to-have，core 行為（`quota_status` tool 可用性）不變。
- 把 OmO 指令 vendor 進 repo：拒絕——日常主力是 matt 工作流（repo 自帶 skills/commands），OmO 指令要用時從 git history 找回即可。

## Consequences

- 放棄：multi-agent 派工名冊（oracle/explore/librarian 等 category 排程）與 cheap-model 排程。接受（使用率低）；core 原生 `task` tool 與 subagents（built-in general/explore）仍在，subagent 能力不受損。
- `small_model` 與 cheap explore agent 不先寫：v2 語法不同（`agents.<id>.model`），等 v2 遷移（backlog ticket 04）一次寫對。
- `guard.ts`（Secret Guard）不動：local plugin 在 v1 下照常運作，gitleaks staged 掃描照舊；v2 需 port 成 `Plugin.define`（見 ticket 04）。`package.json` 的 `@opencode-ai/plugin` 是 guard.ts 的 SDK 依賴，保留。
- Makefile 的 `~/.omo` deploy/uninstall/check 三塊與 `oh-my-openagent.json` legacy cleanup 移除；live 端 `~/.omo/omo.jsonc` stale symlink 清除。
- 回退路徑 = git history。
