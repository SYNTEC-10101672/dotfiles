## Context

- 現況：13 個 `claude/commands/opsx/*.md` 與 13 個 `claude/skills/openspec-*/SKILL.md`，其中 11 組近乎逐字重複（diff 僅差 frontmatter 與 2–3 行措辭），合計 ~4200 行
- 使用者實際流程：`/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:archive`，4 個 slash commands；從不走 `new` / `continue` / `ff` / `onboard` / `sync` / `verify` / `tdd-verify` / `re-verify` / `bulk-archive`
- 既有 wrapper 先例：`commands/opsx/tdd-verify.md`（12 行）只含 frontmatter + input 說明 + 「Use the `openspec-tdd-verify` skill to execute verification」，在 Claude Code 與 opencode 都正常運作
- 既有規格：`openspec/specs/openspec-skill-command-parity/spec.md` mandate 雙檔 body parity，與本變更直接衝突，需重寫
- 檔案透過 dotfiles symlink 同時服務 Claude Code（`~/.claude/`）與 opencode（共用 commands）
- Skill descriptions（`SKILL.md` frontmatter）每個 session 佔 system prompt，commands 只在被 invoke 時載入

### Environment Facts

- 唯一 dangling reference：`claude/skills/openspec-apply-change/SKILL.md:48`（「suggest using openspec-continue-change」，該 skill 將刪除）
- 保留 skills 中其他 cross-reference（`/opsx:apply`、`openspec-sync-specs`、`openspec-tdd-verify`、`openspec-code-review`）皆指向保留對象

## Goals / Non-Goals

**Goals:**

- 消除 command/skill 內容重複：skill 為單一真相來源，command 為 thin wrapper
- 刪除未使用的 9 個 commands 與 6 個死 skills
- 總行數 ~4200 → ~1100 行；system prompt skill descriptions 13 → 7 個
- 修正 `openspec-apply-change/SKILL.md:48` dangling reference
- 重寫 `openspec-skill-command-parity` spec 以反映 wrapper 模型

**Non-Goals:**

- 不修改 7 個保留 skills 的 workflow 內容（除了 line 48 dangling reference）
- 不動 non-opsx 檔案（`commit.md`、`handover.md`、`eli5.md`、grilling 系列 skills）
- 不動 `openspec/changes/archive/` 歷史文件
- 不升級或修改 openspec CLI
- 不改 symlink / Makefile 安裝結構

## Decisions

### D1: Thin wrapper 而非刪除 skills、全文留在 commands

**選擇**：4 個核心 commands 改為 ~12 行 wrapper（frontmatter + 一句用途 + input 說明 + 「Use the `openspec-<name>` skill」），全文只留在 skills。

**理由**：wrapper pattern 已由 `tdd-verify.md` 驗證；全文留在 commands 會使 `apply.md` 需內嵌 3 個 helper skill 內容（~370 行），且失去 skill 懶載入優勢。未來同步 OpenSpec 官方 workflow 更新只需改一份。

**拒絕方案**：刪除核心 skills、commands 持有全文 — 單檔膨脹、需改寫 skill-invocation 機制、改動面大。

### D2: Wrapper 保留 input 說明段落

**選擇**：wrapper 內保留「**Input**: ...」段落（說明 argument 語意），其餘 workflow 全文不複製。

**理由**：input 解析是 command 進入點的第一步，放在 wrapper 讓 slash command 觸發時立即有 context；workflow 步驟由 skill body 提供。

### D3: 一次刪除而非 deprecate 標記

**選擇**：9 個 commands + 6 個 skills 直接刪（git history 保留完整紀錄）。

**理由**：dotfiles 是個人 repo，無下游使用者，不需要 deprecation 週期。留著就是繼續付 system prompt 稅。

### D4: Delta spec 用 REMOVED + ADDED 而非 MODIFIED

**選擇**：parity spec 的 6 個 requirements 以 `## REMOVED Requirements` 整批移除，wrapper 模型以 `## ADDED Requirements` 新增。

**理由**：模型反轉（雙檔等價 → 單一真相 + wrapper），逐條 MODIFIED 會產生假延續性；REMOVED/ADDED 語意誠實。保留適用的舊條文（English prose、frontmatter 不動）以改寫形式納入 ADDED。

## Risks / Trade-offs

- [遺忘的 usage pattern：未來想用 `onboard` 教學或 `bulk-archive` 批次歸檔] → git history 可復原；`sync` 與 `tdd-verify` 功能仍可用（skills 保留，口頭或 `/opsx:tdd-verify` 對應能力由 apply flow 內建）
- [wrapper 指向 skill 在 opencode 的 skill-loading 路徑失效] → `tdd-verify.md` wrapper 已在兩工具驗證；apply 階段 T* 驗證會實測 4 個 wrapper 的 skill 指向
- [openspec CLI 未來更新假設 13 個 commands 存在] → CLI 不依賴 commands（commands 只是 prompt 檔）；spec 重寫後與實際檔案集合一致

## Migration Plan

1. 重寫 4 個核心 commands 為 wrapper（保留 frontmatter 原欄位）
2. 刪除 9 個 commands、6 個 skills
3. 修正 `openspec-apply-change/SKILL.md:48`
4. 驗證：wrapper 指向的 skill 皆存在、無 dangling cross-reference、行數統計符合預期
