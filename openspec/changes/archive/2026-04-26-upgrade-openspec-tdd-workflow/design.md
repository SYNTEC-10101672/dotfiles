## Context

OpenSpec skills 與 commands 存放於 dotfiles repo（`claude/skills/openspec-*/`、`claude/commands/opsx/`），透過 symlink 部署至 `~/.claude/`。這些檔案原從 openspec 1.3.0 複製而來，現需升至 1.3.1 並加入 TDD 客製化。

`openspec update` 指令因 dotfiles project 無 configured tools 設定而無法自動更新，升級須手動複製。

## Goals / Non-Goals

**Goals:**
- 將 11 個上游 skills 與對應 commands 升至 1.3.1
- 新的 tasks.md 格式：測試與實作分離（T* 項目 + 結構化欄位）
- apply 流程支援 TDD 三階段（Red → Green → Final）
- 單元測試評估在 apply 開始時觸發
- tdd-verify 改為 AI 自評驗證可行性，而非預先標注

**Non-Goals:**
- 將客製化提交回 openspec upstream
- 自動化升級流程（維持手動 diff + 複製）
- 支援舊版 `> 驗證：` 格式的自動遷移

## Decisions

### 決策 1：客製化邏輯集中於自有檔案，最小化上游檔案改動

TDD 主要邏輯（Red/Green/Final、AI 自評、T* 格式解析）集中於 `openspec-tdd-verify/SKILL.md`（完全自有，上游無對應檔案）。

`openspec-apply-change/SKILL.md` 與 `commands/opsx/apply.md` 只新增：
1. apply 開始時的單元測試評估步驟
2. 呼叫 openspec-tdd-verify 的時機（Red phase、每個 task 後的 Green phase、最終 Final phase）

**替代方案考慮**：將所有 TDD 邏輯嵌入 apply skill → 被否決，因為未來升級 apply 時衝突面積大。

### 決策 2：T* 測試項目採雙欄位結構（`> 指令：` + `> 預期：`）

分離執行指令與預期結果，讓 tdd-verify skill 能精確對比輸出，而非靠 AI 自行判斷「有沒有通過」。

**替代方案考慮**：inline 格式（全部一行）→ 被否決，長指令可讀性差且難以機器解析。

### 決策 3：single `## 測試` 區塊（集中型），非交錯型

所有 T* 測試集中在一個大區塊，讓使用者在規劃時能一眼掌握所有驗收條件，apply 開始前執行 Red phase 也更直觀。

**替代方案考慮**：測試與實作交錯排列（T1.1 → 1.1 → T1.2 → 1.2）→ 被否決，難以一眼掌握測試全貌。

### 決策 4：單元測試評估在 apply 開始時進行

apply 開始時 AI 掃描 codebase，評估哪些實作 task 值得補充單元測試（基於複雜度、分支邏輯、純函數等判斷），詢問使用者後視情況補充 T* 項目。

tasks.md 生成時（opsx:continue）只寫驗收測試（來自 specs），不預先判斷單元測試需求，因為此時尚未看到程式碼結構。

## Risks / Trade-offs

- **格式不相容**：現有進行中的 change 若有 tasks.md 仍使用 `> 驗證：` 格式，tdd-verify 將無法自動執行。→ 接受此風險，既有 change 數量少，手動更新格式成本低。
- **未來升級**：每次升 openspec 版本需手動 diff apply skill，確認客製化部分未被覆蓋。→ 透過決策 1 最小化改動面積來降低衝突機率。

## Migration Plan

1. 複製 1.3.1 的 11 個上游 skills 與 commands 覆蓋 dotfiles（保留 openspec-tdd-verify 與 tdd-verify.md）
2. 更新 CLAUDE.md 的 OpenSpec 規範段落
3. 改寫 openspec-tdd-verify/SKILL.md（完整新邏輯）
4. 更新 openspec-apply-change/SKILL.md 與 commands/opsx/apply.md（加入 TDD 階段與評估步驟）
5. 更新 openspec-continue-change/SKILL.md（tasks.md 說明）
6. 更新 openspec/specs/openspec-tdd-verify/spec.md（archive 時同步主 spec）

## Open Questions

- 無
