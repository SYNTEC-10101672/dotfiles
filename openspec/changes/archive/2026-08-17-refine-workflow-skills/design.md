# Design: refine-workflow-skills

## Context

本 repo 是個人 dotfiles（`/home/syntec/personal/dotfiles`），其中 `claude/skills/` 收納自訂 agent skills，構成「explore → grill → propose → apply → archive」的 OpenSpec 工作流。經工作流 review 討論，確認 7 項修正決議（4 項需要改檔，其餘為使用紀律）。所有目標檔案皆為 markdown，repo 無測試框架。

### 決議來源（討論結論）

1. ulw 只掛 propose + apply（使用紀律，不改檔）
2. CONTEXT.md：explore / grill / propose 寫，apply 不寫（本 change 改 explore + propose + apply 三個 skill）
3. ADR 自 domain-modeling 移除（本 change 改 domain-modeling + grill-with-docs）
4. T\* 在 propose 生成（本 change 改 propose + apply）
5. fast path：簡單任務直接做（使用紀律）
6. commit：archive 後一次（使用紀律）
7. T\* 是正本（使用紀律）

## Goals / Non-Goals

**Goals:**

- 每個 skill 的職責邊界單一化：domain-modeling 只管 glossary、決策只記 design.md
- T\* 驗收契約在 propose 生成，隨 artifacts 通過 momus + 人工 review
- CONTEXT.md 詞彙維護涵蓋 apply 之前所有階段，apply 不中斷
- 建立「改 skill 前先載 `/writing-great-skills`」的永久規則（路徑無關）

**Non-Goals:**

- 不新增 WORKFLOW.md（使用者自行記憶使用紀律）
- 不修改 `openspec-tdd-verify`、`openspec-archive-change`、`openspec-code-review`（現行行為已符合決議）
- 不為 apply 階段設計詞彙回 flush 機制（使用者選擇接受此縫隙）
- 不動 `grilling` skill（問答行為與 ADR 無關）

## Decisions

### D1: ADR 移除 — 改 `domain-modeling` 本體而非 wrapper

`grill-with-docs` 只是薄 wrapper；若只在 wrapper 層寫「不要 ADR」，`domain-modeling` 本體仍保留 ADR 段落，其他入口引用時行為不一致。使用者自維護此 skill，日後需要 ADR 再從 upstream src repo 加回。連帶刪除孤兒檔 `ADR-FORMAT.md`、同步修 `grill-with-docs` 的 description（其中提及 ADR's）。

- Alternative: 只改 wrapper → 拒絕，理由如上（殘留不一致）

### D2: apply step 5.5 整段刪除 — 不改成「檢查 T\* 存在」

T\* 已在 propose 生成並 review，apply 無需再評估。保留 existence check 會對 docs-only change（合法無 T\*）製造噪音互動。

- Alternative: 5.5 改為存在性檢查 → 拒絕（噪音大於價值）

### D3: CONTEXT.md 寫入時機 — explore / grill / propose 允許，apply 禁止

apply 的目的是不中斷執行任務；期間發現的新詞彙不即時寫回（使用者接受此縫隙，術語先活在 code 裡，下次 grill 自然會撈）。propose skill 在「Fact Lookup」與 artifact 撰寫過程中釐清的詞彙即時寫入；explore skill 加一行對稱指引。

### D4: T\* 驗證形態 — grep / 檔案存在性指令

本 change 全為 markdown 內容變更，repo 無測試框架。T\* 採用可直接執行的 shell 指令（grep 計數、ls 存在性）作為 RED/GREEN 驗證，RED 狀態 = 舊內容仍在（grep 有匹配），GREEN 狀態 = 舊內容已移除（grep 無匹配）。

### D5: skills 維護規範 — 路徑無關的表述

規則寫「任何 agent skill（SKILL.md 及其附屬檔案）」，不綁 `claude/` 資料夾，避免日後 skill 搬家失效。

## Risks / Trade-offs

- [upstream skill 更新時 ADR 段落可能被同步帶回] → 使用者自行比對 src repo；T\* 的 grep 驗證可在當下 change 抓到，長期靠 code review
- [grep 型 T\* 對檔案搬移敏感] → tasks 中路徑全部 pin 死絕對路徑；搬移屬另一 change 範圍
- [apply 期間新詞彙不寫回，glossary 可能 stale] → 已知情接受；下次 grill / explore 會撈回

## Migration Plan

無部署步驟（docs 變更，symlink 目標即 repo 檔案）。Rollback = `git revert`。
