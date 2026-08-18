# Design: replace-writing-great-skills

## Context

- 現況：`claude/skills/writing-great-skills/` 是從 `mattpocock/skills` vendor 的 user-invoked skill（`SKILL.md` 83 行 + `GLOSSARY.md` 201 行 + `agents/openai.yaml` 含 `allow_implicit_invocation: false`）
- Upstream 已改名為 `writing-for-agents`（舊路徑 404、新路徑 200），內容重寫：scope 擴大到所有 agent 消費的文件、GLOSSARY 解散、skill 專屬內容拆到 `SKILL-MECHANICS.md`、改為 model-invoked
- 觸發機制：現行靠 `claude/CLAUDE.md` 第 24-25 行「Skills 維護規範」的必載規則（context pointer）；新版 description 自帶 trigger branches（"Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md"）
- 部署路徑：`~/.claude/skills/` → `dotfiles/claude/skills/` symlink（`claude-config-symlink` capability），改 repo 檔案即生效於新 session

## Goals / Non-Goals

**Goals:**

- `writing-for-agents` 與 upstream main 分支逐字元一致（vendor copy 政策，方便日後 diff/更新）
- Invocation 從 user-invoked + CLAUDE.md pointer 改為 model-invoked description
- 移除 CLAUDE.md 的重複 pointer（anti-duplication）
- 兩個受影響的 specs（`mattpocock-skills`、`skill-authoring-governance`）以 delta specs 更新

**Non-Goals:**

- 不翻譯、不修改 upstream 內容（含 `agents/openai.yaml` 的 display name）
- 不處理其他 4 個 mattpocock skills（`grill-me`、`grilling`、`domain-modeling`、`grill-with-docs`）的 upstream 同步
- 不改動 OpenSpec workflow 相關 skills

## Decisions

### D1: 目錄以 `git mv` 重命名，非刪除重建

`git mv claude/skills/writing-great-skills claude/skills/writing-for-agents` 保留 rename 歷史，之後覆寫檔案內容。git 會偵測 `SKILL.md` 的修改（內容大幅變更但同檔名），`GLOSSARY.md` 以 `git rm` 刪除。

**替代方案**（刪除舊目錄 + 建新目錄）：歷史追蹤斷裂，`git log --follow` 失效。不採。

### D2: Vendor 內容逐字元複製 upstream，零修改

三個檔案直接從 upstream main 分支複製：`SKILL.md`、`SKILL-MECHANICS.md`、`agents/openai.yaml`。

理由：`mattpocock-skills` spec 既有政策是「vendor copy 不修改原檔」，保留與 upstream 的可 diff 性，日後 upstream 演進只需 `curl | diff` 即可驗證。

**替代方案**（只取 SKILL.md、自行補 frontmatter）：破壞 vendor 一致性政策。不採。

### D3: Invocation 改為 model-invoked，CLAUDE.md 指令整節刪除

`claude/CLAUDE.md` 第 24-25 行（`## Skills 維護規範` 標題 + 規則行）整節刪除。

理由：upstream 的 description 已涵蓋原本 CLAUDE.md 指令的觸發範圍（skill 修改），且額外涵蓋 CLAUDE.md / AGENTS.md 編輯 branch。兩者並存 = 同一 trigger 寫兩遍（duplication），每 turn 付雙份 context load。

**替代方案**（保留 CLAUDE.md 行作為硬性保險）：與 model-invoked description 重複；若信任度不足，正確做法是回到 user-invoked（選項 B），而非混合。已在 explore 階段與使用者確認選 A。

### D4: `skill-authoring-governance` spec 改寫而非移除 capability

治理機制從「CLAUDE.md 規則要求必載」改為「model-invoked description 自主觸發」+「CLAUDE.md MUST NOT 含重複 pointer」。保留 capability 是因為它持續承載一個可驗證的 contract：文件寫作治理的觸發路徑與 anti-duplication 約束。

**替代方案**（REMOVED 整個 capability）：anti-duplication 約束（CLAUDE.md 不得回加 pointer）會失去 spec 依據。不採。

## Risks / Trade-offs

- [Model-invoked 觸發是機率性的] → 失敗模式是「文件寫得不夠好」而非災難，可接受；必要時使用者仍可手動 `/writing-for-agents`（model-invoked 包含 user reach）
- [Skill 改名後，進行中 session 的舊名引用失效] → 舊 session 重啟即載入新 skill；repo 內已無其他舊名引用（已掃描確認）
- [Upstream 內容日後再變] → vendor 政策本來就是手動同步；`mattpocock-skills` spec 的「安裝來源可追溯」requirement 已要求記錄 upstream URL

## Migration Plan

1. `git mv` 重命名目錄 → 覆寫 3 檔 → 刪 `GLOSSARY.md`
2. 刪 `claude/CLAUDE.md` 第 24-25 行
3. 驗證：檔案與 upstream diff 為空、frontmatter 無 `disable-model-invocation`、`~/.claude/skills/` 透通顯示新目錄名
4. Rollback：`git revert` 即可（純檔案變更，無 state）

## Open Questions

（無）
