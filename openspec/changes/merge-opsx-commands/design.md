# Design: merge-opsx-commands

## Context

現行架構（由 `openspec/specs/openspec-skill-command-parity/spec.md` 規範）：`opencode/commands/opsx/` 內 4 個 slash commands 為 thin wrapper，只含 frontmatter、一句用途、Input 段、skill 指向；workflow 內容存在 4 個 entry skills（`opencode/skills/openspec-{explore,propose,apply-change,archive-change}/SKILL.md`）。另有 4 個 helper skills（`openspec-tdd-verify`、`openspec-code-review`、`openspec-artifact-review`、`openspec-sync-specs`）被流程中途引用——其中 `openspec-artifact-review`（propose 流程 spawn）與 `openspec-sync-specs`（archive 流程 spawn）依賴 `task(load_skills=[...])` 注入 sub-agent，`openspec-tdd-verify` 與 `openspec-code-review` 由主 agent 以 skill tool 中途載入。

部署機制：`Makefile` 的 `opencode` target 以**目錄級 symlink** 部署（`~/.config/opencode/commands` → `dotfiles/opencode/commands`、`~/.config/opencode/skills` → `dotfiles/opencode/skills`），repo 內容變更即時反映於部署端，無 per-file symlink 清理問題。

實際使用模式：使用者一律經 slash command 啟動 opsx 流程；entry skills 的 model-invoked 自動路由（agent 依 skill description 自主載入）從未是進入點。

## Goals / Non-Goals

**Goals:**

- 4 個 slash commands 成為 workflow 內容的單一真相來源（內容自足，啟動時直接送達，少一次 skill tool 跳轉）
- 消除 command/skill 雙檔重複維護（Input 段、wrapper 同步約束）
- 歸屬明確化：commands = 使用者主動啟動的流程本體；skills = 流程共用的 agent-loadable helpers
- 7 個受影響 capability specs 的路徑引用、流程識別字、保留集合同步更新，無 dangling reference

**Non-Goals:**

- 不改任何 workflow 的行為內容（合併是逐字搬移＋機械調整，不順手改流程邏輯）
- 不動 4 個 helper skills 與 `domain-modeling` 等 非 openspec skills
- 不引入 `$ARGUMENTS` 樣板或 command frontmatter 新欄位（Input 維持 prose 描述）
- 不處理 openspec CLI 未來版本的 vendor 更新（ownership 已完全轉移，上游同步不再適用）

## Decisions

### D1: 只合併 4 個 entry skills，helper skills 維持 skills 形式

**替代方案**：8 個 skills 全部併入 commands（使用者最初提案）。

**不採納原因**：`openspec-artifact-review` 與 `openspec-sync-specs` 靠 `task(load_skills=[...])` 注入 sub-agent，commands 無此機制；併入代表 spawn 時須把完整 brief 內嵌進母檔案再複製進 prompt，`apply.md` 將膨脹至約 350 行且產生 brief 重複。Helper skills 的 skill description 亦持續供主 agent 在流程中途依名載入。

### D2: 內容逐字搬移，僅做 5 項機械調整

合併時對 skill body 做且只做：

1. 刪除「Use the `openspec-<name>` skill to run this workflow.」指向行
2. Input 段去重：command 與 skill 各有一份，保留較完整版（skill 版）
3. 刪除 `<!-- CUSTOM: ... -->` / `<!-- /CUSTOM: ... -->` vendor diff markers（ownership 轉移後無對上游 diff 的需求）
4. explore / propose 內「同 skills 目錄下」（same skills directory）的相對路徑措辭，改為明確路徑 `opencode/skills/domain-modeling/`（脫離 skill 目錄結構後相對語意失效）
5. Skill frontmatter 專屬欄位（`license`、`compatibility`、`metadata`）不帶入；command 維持既有 frontmatter（`name`、`description`、`category`、`tags`）。`Requires openspec CLI` 不另保留——body 步驟本身執行 `openspec` 指令，自明

**理由**：逐字搬移使 diff review 與行為等價驗證最容易；5 項調整皆為脫離 skill 脈絡後的必要修正，非行為變更。

### D3: Specs 流程識別字統一原則

- 行為引用（誰在什麼階段做什麼）：用 slash form——`/opsx:explore`、`/opsx:propose`、`/opsx:apply`、`/opsx:archive`
- 檔案存在性或內容檢查（WHEN 讀取／檢視）：用 repo 相對路徑——`opencode/commands/opsx/explore.md` 等

**理由**：slash form 是使用者與 agent 共同的流程介面；路徑 form 供 spec scenario 直接對應可驗證檔案。skill 名（`openspec-explore` 等）在本變更後不存在，續用即 dangling reference。

### D4: 執行順序——內容合併先行，skill 目錄刪除殿後

1. 4 個 commands 內容合併（舊 wrapper 內容被取代）
2. 7 個主 specs 的 delta 產出（本 change artifacts）與 sync
3. `make opencode` 部署驗證
4. 最後刪除 4 個 entry skill 目錄

**理由**：本 change 修改的正是執行中流程的檔案。目錄 symlink 即時生效，但 apply 流程只引用 helper skills（本 change 不動）；entry skill 刪除時，正在執行的 flow 指令已在 session context 中，不受影響。內容先就位，任何中斷點的檔案狀態都保持可用。

### D5: 合併後 ownership 規則寫入 parity spec

`openspec-skill-command-parity` 的 Purpose 改寫為：commands = workflow 內容單一真相來源；skills（`openspec-*` 前綴）僅存 helper 角色，MUST 被至少一個流程或 agent 引用，不得是無 command 對應的孤兒 entry——此規則取代原 thin-wrapper 約束，防止未來不小心長回雙層結構。

## Risks / Trade-offs

- [失去 model-invoked 自動路由] → 接受。使用者一律經 slash command 啟動；明示啟動同時消除 agent 自作主張進入 workflow 的風險。後果：未來 session 不打 slash 時，agent 不認得 `/opsx:*` 流程的存在
- [自舉風險：apply 修改執行中的流程檔案] → D4 順序約束 + apply 只依賴 helper skills + 任何中斷點檔案狀態可用（commands 新內容即時經 symlink 生效）
- [7 個 specs MODIFIED 範圍不小] → 其中 4 個（`skill-authoring-governance`、`spec-test-contract`、`openspec-code-review`、`self-contained-tasks`）是路徑字串替換，2 個（`glossary-maintenance`、`artifact-review-gate`）是識別字替換，行為語意皆不變；真正的結構重寫只有 `openspec-skill-command-parity`
- [vendor 更新歷史成本消失，但也永久放棄上游同步] → 接受。4 個 entry skills 已深度客製（artifact-review gate、TDD 三階段、英文 token、guardrails），上游覆蓋本來就會破壞客製

## Migration Plan

apply 依 D4 順序執行；每步對應 tasks.md 任務與 T* 驗證。Rollback：`git revert` 即可——目錄 symlink 使部署端隨 repo 自動回滾，無部署端手續。最終行為驗證：合併後開新 session 執行 `/opsx:explore`，確認內容直接送達（無 skill tool 跳轉）。

## Open Questions

（無——方案 B、helper 保留、vendor markers 刪除、不引入 $ARGUMENTS 已於 explore 階段與使用者定調）
