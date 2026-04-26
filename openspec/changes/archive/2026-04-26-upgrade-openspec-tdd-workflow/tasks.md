## 測試

- [x] T1 上游 skills 版本號更新至 1.3.1
  > 指令：`grep "generatedBy" /home/s911336/Projects/dotfiles/claude/skills/openspec-apply-change/SKILL.md`
  > 預期：輸出包含 `"1.3.1"`

- [x] T2 CLAUDE.md 不再包含舊 `> 驗證：` 格式說明
  > 指令：`grep -c "驗證：" /home/s911336/Projects/dotfiles/claude/CLAUDE.md`
  > 預期：輸出 `0`（完全移除舊格式規範）

- [x] T3 tdd-verify SKILL.md 包含新格式關鍵詞
  > 指令：`grep -c "指令：\|預期：\|Red phase\|Green phase" /home/s911336/Projects/dotfiles/claude/skills/openspec-tdd-verify/SKILL.md`
  > 預期：輸出 `4`（四個關鍵詞皆存在）

- [x] T4 apply command 包含 TDD 三階段關鍵詞
  > 指令：`grep -E "Red|Green|Final" /home/s911336/Projects/dotfiles/claude/commands/opsx/apply.md | wc -l`
  > 預期：輸出 `3` 或以上

- [x] T5 continue skill 包含新 tasks.md 格式說明
  > 指令：`grep -c "## 測試\|T\*\|測試區塊" /home/s911336/Projects/dotfiles/claude/skills/openspec-continue-change/SKILL.md`
  > 預期：輸出 `1` 或以上

- [x] T6 /opsx:upgrade command 存在且包含排除清單關鍵詞
  > 指令：`grep -c "openspec-tdd-verify\|tdd-verify.md" /home/s911336/Projects/dotfiles/claude/commands/opsx/upgrade.md`
  > 預期：輸出 `2`（兩個排除項目皆存在）

## 實作

## 1. 升級上游 skills 至 1.3.1

- [x] 1.1 從 1.3.1 temp 目錄複製 11 個上游 skills（覆蓋 dotfiles，保留 openspec-tdd-verify）（→ T1）
- [x] 1.2 從 1.3.1 temp 目錄複製 11 個上游 commands（覆蓋 dotfiles，保留 tdd-verify.md）（→ T1）

## 2. 更新 CLAUDE.md

- [x] 2.1 將 OpenSpec 規範段落改為新格式說明：tasks.md 使用 `## 測試` / `## 實作` 雙區塊，T* 項目含 `> 指令：` 與 `> 預期：`（→ T2）

## 3. 改寫 openspec-tdd-verify SKILL.md

- [x] 3.1 改寫 openspec-tdd-verify/SKILL.md：讀取 T* 項目的 `> 指令：` 與 `> 預期：`，支援 Red phase / Green phase / Final phase（→ T3）
- [x] 3.2 加入 AI 自評驗證可行性邏輯：不確定時提出替代方案詢問使用者，而非直接標注「無法自動驗證」（→ T3）

## 4. 更新 opsx:apply TDD 流程

- [x] 4.1 更新 openspec-apply-change/SKILL.md：apply 開始時加入單元測試評估步驟（掃描 codebase → 詢問使用者 → 視情況補充 T*）（→ T4）
- [x] 4.2 更新 openspec-apply-change/SKILL.md：Step 6 改為 TDD 三階段——先執行 Red phase（全部 T* 確認 fail）、逐 task 實作後執行 Green phase（對應 T*）、最終 Final phase（全部 T* 再跑一遍）（→ T4）
- [x] 4.3 同步更新 commands/opsx/apply.md（內容與 SKILL.md 保持一致）（→ T4）

## 5. 更新 openspec-continue-change

- [x] 5.1 更新 openspec-continue-change/SKILL.md 的 tasks.md 說明：加入新格式描述（`## 測試` 區塊先於 `## 實作` 區塊，T* 項目含結構化欄位）（→ T5）

## 6. 更新 tdd-verify command

- [x] 6.1 更新 commands/opsx/tdd-verify.md 的 description，與新邏輯同步（→ T3）

## 7. 更新主 spec

- [x] 7.1 更新 openspec/specs/openspec-tdd-verify/spec.md，反映新的 T* 格式與 AI 自評驗證邏輯（archive 時同步）

## 8. 新增 /opsx:upgrade command

- [x] 8.1 建立 claude/commands/opsx/upgrade.md：版本比對、diff 摘要、使用者確認、複製新版 skills/commands（跳過排除清單）（→ T6）
