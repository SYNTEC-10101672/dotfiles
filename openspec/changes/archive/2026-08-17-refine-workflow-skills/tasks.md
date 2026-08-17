# Tasks: refine-workflow-skills

## 1. 前置規範

- [x] 1.1 載入 `/writing-great-skills`（本 change 修改多個 skill 檔案，適用 Skills 維護規範；規則本體由 task 3.1 寫入 CLAUDE.md）→ T8

## 2. 移除 domain-modeling 的 ADR 功能

- [x] 2.1 編輯 `claude/skills/domain-modeling/SKILL.md`：刪除 file structure 中 `docs/adr/` 相關行、「Offer ADRs sparingly」整段（含 ADR-FORMAT.md 連結）→ T1
- [x] 2.2 刪除 `claude/skills/domain-modeling/ADR-FORMAT.md` → T2
- [x] 2.3 編輯 `claude/skills/grill-with-docs/SKILL.md`：description 移除 "(ADR's and glossary)" 中的 ADR 字樣，改為只提 glossary / CONTEXT.md → T3

## 3. CLAUDE.md 新增 Skills 維護規範

- [x] 3.1 編輯 `claude/CLAUDE.md`：新增一節「## Skills 維護規範」，內容為「修改或新增任何 agent skill（SKILL.md 及其附屬檔案）前，必須先載入 `/writing-great-skills`」（路徑無關表述）→ T8

## 4. openspec-propose：T\* 生成 + CONTEXT.md 維護

- [x] 4.1 編輯 `claude/skills/openspec-propose/SKILL.md`：在 tasks artifact 指引中加入「生成 tasks.md 時必須同時產出 `## Tests` section 的 T\* 項目（格式：`- [ ] T<n>: 描述` + `> Command:` + `> Expected:`，與 openspec-tdd-verify 相容）；docs-only change 無可執行驗證時，在 tasks.md 記載豁免理由」→ T6
- [x] 4.2 編輯 `claude/skills/openspec-propose/SKILL.md`：加入「Fact Lookup 與 artifact 撰寫過程釐清的領域詞彙，即時寫入專案 CONTEXT.md（依 domain-modeling 的 CONTEXT-FORMAT.md 格式，lazily 建立）」→ T7

## 5. openspec-apply-change：刪除 step 5.5

- [x] 5.1 編輯 `claude/skills/openspec-apply-change/SKILL.md`：整段刪除「5.5 Unit test assessment (at apply start)」（含 fire explore、AskUserQuestion、加 T\* 的描述）；後續步驟編號 6/7/8 保持不動；不新增任何 CONTEXT.md 相關行（缺席即禁止）→ T4

## 6. openspec-explore：CONTEXT.md 維護指引

- [x] 6.1 編輯 `claude/skills/openspec-explore/SKILL.md`：在「What You Might Do」或 Guardrails 適當位置加一行「釐清的領域詞彙即時寫入專案 CONTEXT.md（依 domain-modeling 格式）」→ T5

## Tests

- [x] T1: domain-modeling SKILL.md 不再提及 ADR
  > Command: `grep -ci "ADR" claude/skills/domain-modeling/SKILL.md`
  > Expected: `0`（修改前 ≥ 5，Red phase 應失敗）
- [x] T2: ADR-FORMAT.md 已刪除
  > Command: `ls claude/skills/domain-modeling/ADR-FORMAT.md 2>&1; echo "exit=$?"`
  > Expected: 輸出含 `No such file or directory` 且 `exit=2`（修改前檔案存在，Red phase 應失敗）
- [x] T3: grill-with-docs description 不含 ADR 字樣
  > Command: `grep -ci "ADR" claude/skills/grill-with-docs/SKILL.md`
  > Expected: `0`（修改前為 1）
- [x] T4: apply skill 不含 step 5.5 unit test assessment
  > Command: `grep -c "Unit test assessment" claude/skills/openspec-apply-change/SKILL.md`
  > Expected: `0`（修改前為 1）
- [x] T5: explore skill 含 CONTEXT.md 維護指引
  > Command: `grep -c "CONTEXT.md" claude/skills/openspec-explore/SKILL.md`
  > Expected: `≥ 1`（修改前為 0）
- [x] T6: propose skill 含 T\* 生成指引
  > Command: `grep -c '## Tests' claude/skills/openspec-propose/SKILL.md`
  > Expected: `≥ 1`（修改前為 0；注意不能用 `T\*` 當關鍵字 — line 119 既有 "The corresponding T\* can be executed" 已含此字樣）
- [x] T7: propose skill 含 CONTEXT.md 維護指引
  > Command: `grep -c "CONTEXT.md" claude/skills/openspec-propose/SKILL.md`
  > Expected: `≥ 1`（修改前為 0）
- [x] T8: CLAUDE.md 含 writing-great-skills 規範
  > Command: `grep -c "writing-great-skills" claude/CLAUDE.md`
  > Expected: `≥ 1`（修改前為 0）
