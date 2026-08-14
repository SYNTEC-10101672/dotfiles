## Tests

- [x] T1 openspec-tdd-verify SKILL.md 結構與語言
  > Command: `bash -c 'steps=$(grep -c "^[0-9]\. \*\*" claude/skills/openspec-tdd-verify/SKILL.md); chinese=$(grep -P "[\x{4e00}-\x{9fff}]" claude/skills/openspec-tdd-verify/SKILL.md | grep -v "驗證：" | grep -v "^---" | grep -v "description:"); echo "steps=$steps"; echo "chinese_lines=$chinese"; head -4 claude/skills/openspec-tdd-verify/SKILL.md'`
  > Expected: steps=6；chinese_lines 為空（無中文殘留，`> 驗證：` legacy literal 除外）；frontmatter 含 `name: openspec-tdd-verify` 與 `description:` 含 `Command/Expected`

- [x] T2 opsx/tdd-verify.md + opsx/re-verify.md 語言與 delegation
  > Command: `bash -c 'chinese=$(grep -P "[\x{4e00}-\x{9fff}]" claude/commands/opsx/tdd-verify.md claude/commands/opsx/re-verify.md); echo "chinese=$chinese"; grep "openspec-tdd-verify" claude/commands/opsx/tdd-verify.md claude/commands/opsx/re-verify.md'`
  > Expected: chinese 為空；delegation 行存在於兩個檔案（`Use the openspec-tdd-verify skill...`）

- [x] T3 五個 token-swap 檔案不含舊中文 token
  > Command: `grep -rn '## 測試\|## 實作\|> 指令：\|> 預期：\|（→ T' claude/skills/openspec-apply-change/SKILL.md claude/skills/openspec-continue-change/SKILL.md claude/commands/opsx/apply.md claude/commands/opsx/continue.md claude/commands/handover.md`
  > Expected: 無輸出（exit code 1，grep 找不到任何 match）

- [x] T4 新英文 token 存在於所有應修改的檔案
  > Command: `grep -rl '## Tests' claude/skills/openspec-apply-change/SKILL.md claude/skills/openspec-continue-change/SKILL.md claude/commands/opsx/apply.md claude/commands/opsx/continue.md && grep '## Implementation' claude/commands/handover.md`
  > Expected: 4 個檔案被 listed（含 `## Tests`）；handover.md 含 `## Implementation`

- [x] T5 CLAUDE.md 已刪除 `## OpenSpec 規範` section
  > Command: `grep -c '## OpenSpec 規範' claude/CLAUDE.md`
  > Expected: 0

- [x] T6 全域確認：claude/ 內無殘留舊中文 token（排除 archive、legacy guard literal）
  > Command: `grep -rn '## 測試\|## 實作\|> 指令：\|> 預期：\|（→ T' claude/ --include="*.md" | grep -v 'changes/archive/' | grep -v '驗證：' | grep -v 'openspec/changes/opsx-english-tokens/'`
  > Expected: 無輸出（exit code 1）

## Implementation

- [x] 1.1 重寫 `claude/skills/openspec-tdd-verify/SKILL.md` 全文為英文（→ T1）
  - 保留 6-step 結構、frontmatter keys（`name`、`description`）
  - frontmatter description 改為：`Execute TDD verification for OpenSpec tasks using T* items with structured Command/Expected fields. Supports Red phase (before impl), Green phase (after each task), and Final phase (all tests).`
  - `## Tests` 取代 `## 測試`；`> Command:` 取代 `> 指令：`；`> Expected:` 取代 `> 預期：`
  - 保留 `> 驗證：` legacy guard（偵測 literal 維持中文，guard message 改英文）
  - skill output 訊息改英文：`✓ T<n> passed → marked [x]`、`⚠ Manual verification:` 等

- [x] 1.2 翻譯 `claude/commands/opsx/tdd-verify.md` intro + Input 為英文（→ T2）
  - line 8 改為：`Execute verification of T* items in the tasks.md ## Tests block; mark [x] based on results.`
  - line 10 改為：`**Input**: phase (Red / Green / Final) and corresponding T* numbers, or infer from context.`
  - line 12 delegation 行不動

- [x] 1.3 翻譯 `claude/commands/opsx/re-verify.md` intro + step 1-2 為英文（→ T2）
  - description line 3：`## 測試` → `## Tests`
  - line 8 改為英文 intro
  - step 1-2 改為英文（token swap：`## Tests`、`## Implementation`）
  - step 3（line 26）已經是英文，不動

- [x] 2.1 Token swap `claude/skills/openspec-apply-change/SKILL.md` + `claude/commands/opsx/apply.md`（→ T3, T4）
  - apply-change/SKILL.md line 71, 78：`## 測試` → `## Tests`
  - apply.md line 67, 74：`## 測試` → `## Tests`

- [x] 2.2 Token swap `claude/skills/openspec-continue-change/SKILL.md` + `claude/commands/opsx/continue.md`（→ T3, T4）
  - continue-change/SKILL.md line 105：`## 測試`→`## Tests`、`## 實作`→`## Implementation`、`> 指令：`→`> Command:`、`> 預期：`→`> Expected:`、`（→ T<n>）`→`(→ T<n>)`
  - continue.md line 101：同上

- [x] 2.3 Token swap `claude/commands/handover.md`（→ T3, T4）
  - line 37：`## 實作` → `## Implementation`

- [x] 3.1 刪除 `claude/CLAUDE.md` 整段 `## OpenSpec 規範`（→ T5）
  - 刪除從 `## OpenSpec 規範` heading 到下一個 `##` heading 之前的所有內容（5 條規則）
  - 不動其他 section
