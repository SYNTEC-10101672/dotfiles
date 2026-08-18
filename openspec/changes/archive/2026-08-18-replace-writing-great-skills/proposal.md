# Proposal: replace-writing-great-skills

## Why

Upstream `mattpocock/skills` 已將 `writing-great-skills` 重新命名並改寫為 `writing-for-agents`（舊路徑 `skills/productivity/writing-great-skills/SKILL.md` 已 404）。新版將 scope 從「寫 skill」擴大到「寫任何 agent 消費的文件」（含 `AGENTS.md` / `CLAUDE.md`），並改為 model-invoked —— description 本身就是觸發器，不再需要 `CLAUDE.md` 裡的「必須先載入」pointer。現行 repo 的 user-invoked + CLAUDE.md 提醒行的混合架構，若保留會與 model-invoked description 形成 duplication（同一 trigger 兩處），且 CLAUDE.md 那行蓋不到「編輯 CLAUDE.md 本身」這個新版涵蓋的 branch。

## What Changes

- **重新命名 skill 目錄**：`claude/skills/writing-great-skills/` → `claude/skills/writing-for-agents/`
- **Vendor 新版內容**（與 upstream `skills/productivity/writing-for-agents/` main 分支完全一致）：
  - `SKILL.md` — model-invoked（無 `disable-model-invocation: true`），description 為 `Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md.`
  - `SKILL-MECHANICS.md` — 新增檔案（skill 專屬 branch：frontmatter、invocation choice、router skills）
  - `agents/openai.yaml` — 換為 upstream 版本（移除 `policy.allow_implicit_invocation: false`，即 model-invoked）
- **刪除 `GLOSSARY.md`** — 新版將定義 inline 進各節，不再有 glossary
- **刪除 `claude/CLAUDE.md` 的「Skills 維護規範」行**（第 25 行「修改或新增任何 agent skill 前必須先載入 `/writing-great-skills`」）— invocation 職責改由 skill description 承擔
- **BREAKING**（對 skill 引用者）：skill 名稱從 `writing-great-skills` 改為 `writing-for-agents`，任何以舊名引用的地方都會失效（已掃描：repo 內僅 `claude/CLAUDE.md` 與兩個 spec 引用，均在本變更處理範圍內）

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `mattpocock-skills`: vendor 對應關係變更 —— `writing-for-agents/SKILL.md` ← `skills/productivity/writing-for-agents/SKILL.md`（附帶檔案從 `GLOSSARY.md` 改為 `SKILL-MECHANICS.md` + `agents/openai.yaml`）；invocation 分類變更 —— `writing-for-agents` 從 user-invoked 改為 model-invoked；「不影響既有 skills」保護清單更新 —— `writing-great-skills` → `writing-for-agents`（本變更即為該 rename 的授權來源）
- `skill-authoring-governance`: 治理機制變更 —— 從「CLAUDE.md 規則要求修改 skill 前必須載入 `/writing-great-skills`」改為「`writing-for-agents` 以 model-invoked description 自主觸發（涵蓋 skill 修改與 `AGENTS.md`/`CLAUDE.md` 編輯 branches）」，且 `claude/CLAUDE.md` MUST NOT 保留重複的 loading 指令

## Impact

- `claude/skills/writing-great-skills/`（3 個檔案：`SKILL.md`、`GLOSSARY.md`、`agents/openai.yaml`）→ 重命名目錄、換內容、刪 `GLOSSARY.md`、新增 `SKILL-MECHANICS.md`
- `claude/CLAUDE.md`（「Skills 維護規範」一節刪除）
- `openspec/specs/mattpocock-skills/spec.md`、`openspec/specs/skill-authoring-governance/spec.md`（delta specs）
- 部署面：透過既有 `~/.claude/skills/` symlink，新 session 自動生效；進行中的 session 不受影響
- Upstream 來源：`https://github.com/mattpocock/skills`（main 分支，`skills/productivity/writing-for-agents/`）
