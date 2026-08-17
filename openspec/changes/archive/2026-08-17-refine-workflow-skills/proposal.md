# Proposal: refine-workflow-skills

## Why

工作流 review 討論發現現行 skill 流程有職責牴觸與覆蓋破洞：ADR 與 design.md 兩本帳、T\* 驗收項目在人工 review 之後才誕生、CONTEXT.md glossary 只在 grill 階段維護。這些問題會隨 change 數量累積放大（glossary stale、spec 失真、review 砺空），需要一次修正。

## What Changes

- 移除 `domain-modeling` 的 ADR 功能（SKILL.md 相關段落 + 刪除 `ADR-FORMAT.md`），決策統一由 design.md 記錄；日後需要再從 upstream src repo 加回
- `grill-with-docs` description 移除 ADR 字樣，反映新行為
- `openspec-propose` 生成 tasks.md 時同時產出 T\* 測試項目（驗收契約提前到 momus + 人工 review 之前），並在 propose 期間維護 CONTEXT.md
- `openspec-apply-change` 刪除 step 5.5（unit test assessment），apply 全程不寫 CONTEXT.md 以避免中斷任務執行
- `openspec-explore` 加入 CONTEXT.md 詞彙維護指引
- `claude/CLAUDE.md` 新增「Skills 維護規範」：修改任何 agent skill 前必須先載入 `/writing-great-skills`（不綁定特定資料夾路徑）

## Capabilities

### New Capabilities

- `skill-authoring-governance`: agent skill 檔案的維護紀律 — 修改任何 skill 前必須先載入 `/writing-great-skills`（不綁路徑）
- `spec-test-contract`: T\* 驗收項目在 propose 階段生成並隨 artifacts 接受 review；apply 階段不再另行生成
- `glossary-maintenance`: CONTEXT.md 詞彙在 explore / grill / propose 階段維護；apply 階段禁止寫入

### Modified Capabilities

（無 — 本 repo 的 `openspec/specs/` 目前沒有既有 specs，全部為新增）

## Impact

- 檔案：`claude/skills/domain-modeling/SKILL.md`、`claude/skills/domain-modeling/ADR-FORMAT.md`（刪除）、`claude/skills/grill-with-docs/SKILL.md`、`claude/skills/openspec-propose/SKILL.md`、`claude/skills/openspec-apply-change/SKILL.md`、`claude/skills/openspec-explore/SKILL.md`、`claude/CLAUDE.md`
- 全為 markdown/docs 變更，無程式碼、無依赖、無 breaking change
- 連帶消解的既有問題：決策重複記錄於 ADR 與 design.md 兩處、ADR 產物無下游讀取、T\* 驗收項目未經人工 review、CONTEXT.md 在 apply 階段之後詞彙斷裂
