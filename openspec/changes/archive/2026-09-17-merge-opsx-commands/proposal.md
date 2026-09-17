# Proposal: merge-opsx-commands

## Why

opsx workflow 的唯一實際進入點是 slash commands（`/opsx:explore`、`/opsx:propose`、`/opsx:apply`、`/opsx:archive`），但現行架構下 commands 只是 thin wrapper，真正內容在 4 個 entry skills——每次啟動流程都多一次 skill tool 載入跳轉，Input 段落在 command 與 skill 兩處重複維護，且 wrapper 與 skill 的同步由 `openspec-skill-command-parity` spec 強制約束，維護成本大於收益。這 4 個 entry skills 原為 openspec CLI 產生的 vendor 檔案，現已深度客製（artifact-review gate、TDD 三階段、英文 token、guardrails），繼續放在 vendor 管理的 skills 目錄只會造成歸屬混淆。Helper skills（被流程中途引用、其中 2 個依賴 `task(load_skills=[...])` 注入 sub-agent）不在此列，維持 skills 形式。

## What Changes

- `opencode/commands/opsx/explore.md`、`propose.md`、`apply.md`、`archive.md` 從 thin wrapper 改為 workflow 內容本體：對應 skill body 逐字合併進 command，僅做機械調整（刪除 skill 指向行、Input 段去重、刪 vendor CUSTOM markers、「同 skills 目錄下」相對措辭改明確路徑）
- 刪除 4 個 entry skills 目錄：`opencode/skills/openspec-explore/`、`opencode/skills/openspec-propose/`、`opencode/skills/openspec-apply-change/`、`opencode/skills/openspec-archive-change/`
- 保留 4 個 helper skills：`openspec-tdd-verify`、`openspec-code-review`、`openspec-artifact-review`、`openspec-sync-specs`（`domain-modeling`、`grilling`、`tutoring`、`writing-for-agents` 等非 openspec skills 亦不動）。Helper skills 功能內容不變，僅 frontmatter description 中的舊流程名識別字替換為 slash form（`openspec-code-review` 的 "openspec-apply completes" → "`/opsx:apply` completes"；`openspec-artifact-review` 的 "openspec-propose completes" → "`/opsx:propose` completes"），消除 dangling reference
- 合併後 command 內文對 helper skills 的引用字句不變（主 agent 仍以 skill tool 載入；sub-agent spawn 模式不受影響）
- **BREAKING**（agent 行為）：4 個 entry flows 從 model-invoked skill 清單消失——未來 session 中不打 slash command 時，agent 不會再自動辨識並載入這些流程；流程只能經 slash command 明示啟動
- 7 個 capability specs 的 requirement 更新（路徑引用、流程識別字、保留集合）

## Capabilities

### New Capabilities

（無——本變更為既有架構重組，不新增 capability）

### Modified Capabilities

- `openspec-skill-command-parity`: 核心重構——commands 從 thin wrapper 改為內容自足的單一真相來源；保留集合由「4 commands + 8 skills」改為「4 commands + 4 helper skills」；dangling cross-reference 約束對象調整為合併後的檔案集合
- `skill-authoring-governance`: `opencode/skills/openspec-explore/SKILL.md` 與 `opencode/skills/openspec-propose/SKILL.md` 的路徑引用改為 `opencode/commands/opsx/explore.md` 與 `opencode/commands/opsx/propose.md`
- `spec-test-contract`: scenario 中 `opencode/skills/openspec-apply-change/SKILL.md` 路徑引用改為 `opencode/commands/opsx/apply.md`
- `openspec-code-review`: requirement 與 scenarios 中 `openspec-apply-change/SKILL.md` 路徑引用改為 `opencode/commands/opsx/apply.md`
- `self-contained-tasks`: requirement 中 `openspec-propose/SKILL.md` 引用（含歷史行號）改為 `opencode/commands/opsx/propose.md`，行為規則本身不變
- `glossary-maintenance`: 流程識別字由 skill 名（`openspec-explore`、`openspec-propose`、`openspec-apply-change`）改為 slash command 名（`/opsx:explore`、`/opsx:propose`、`/opsx:apply`）
- `artifact-review-gate`: 發起端識別字由 `openspec-propose`（skill）改為 `/opsx:propose`（command 流程），審查契約本身不變

## Impact

- 檔案：`opencode/commands/opsx/` 4 檔改寫（合併後各約 165–310 行）；`opencode/skills/` 4 目錄刪除；7 個 delta specs 隨本 change 產出，archive 時 sync 進主 specs
- 部署：`~/.config/opencode/skills` 與 `~/.config/opencode/commands` 皆為目錄級 symlink（`Makefile` `opencode` target），repo 變更即時反映，無 stale symlink 清理負擔
- 自舉風險：本 change 修改的正是 opsx 流程檔案本身——apply 執行期間只引用 helper skills（本 change 不動），entry skill 目錄刪除排在 4 個 commands 內容合併驗證通過之後
- 未來 session：model-invoked skill 清單少 4 個 entry flows；`/opsx:*` 啟動行為不變且少一次 skill tool 跳轉
