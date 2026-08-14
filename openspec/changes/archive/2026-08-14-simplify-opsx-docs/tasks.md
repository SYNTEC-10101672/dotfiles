# Tasks

## 1. Wrapper 化 4 個核心 commands

- [x] 1.1 重寫 `claude/commands/opsx/explore.md` 為 thin wrapper：保留原 frontmatter（name: "OPSX: Explore" 等 4 欄位），body 只含一句用途說明 + `**Input**` 段落（沿用原檔 5 種 input 類型描述）+ 「Use the `openspec-explore` skill」指向，總行數 ≤ 20 → T1, T6
- [x] 1.2 重寫 `claude/commands/opsx/propose.md` 為 thin wrapper：保留原 frontmatter，body 只含用途說明 + `**Input**` 段落（change name 或描述）+ 「Use the `openspec-propose` skill」指向，總行數 ≤ 20 → T1, T6
- [x] 1.3 重寫 `claude/commands/opsx/apply.md` 為 thin wrapper：保留原 frontmatter，body 只含用途說明 + `**Input**` 段落（optional change name，省略時從 context 推斷或詢問）+ 「Use the `openspec-apply-change` skill」指向，總行數 ≤ 20 → T1, T6
- [x] 1.4 重寫 `claude/commands/opsx/archive.md` 為 thin wrapper：保留原 frontmatter，body 只含用途說明 + `**Input**` 段落（optional change name）+ 「Use the `openspec-archive-change` skill」指向，總行數 ≤ 20 → T1, T6

## 2. 刪除未使用檔案

- [x] 2.1 刪除 9 個 commands：`claude/commands/opsx/` 下的 `new.md`、`continue.md`、`ff.md`、`onboard.md`、`sync.md`、`verify.md`、`tdd-verify.md`、`re-verify.md`、`bulk-archive.md` → T2
- [x] 2.2 刪除 6 個 skills 目錄：`claude/skills/` 下的 `openspec-new-change/`、`openspec-continue-change/`、`openspec-ff-change/`、`openspec-onboard/`、`openspec-verify-change/`、`openspec-bulk-archive-change/` → T3

## 3. 修正 dangling reference

- [x] 3.1 修正 `claude/skills/openspec-apply-change/SKILL.md` blocked-state 指引（原 line 48「suggest using openspec-continue-change」）：改為建議先建立缺少的 artifacts（例如「suggest creating the missing artifacts first (see artifact dependencies in `openspec status`)"），全文英文，不動該檔其他內容 → T4

## 4. 最終驗證

- [x] 4.1 執行下方全部 T* 驗證並確認通過；統計 `claude/commands/opsx/` + 7 個保留 skills 的總行數 ≤ 1200 → T5

## Tests

- [x] T1 4 個 wrapper 均為 thin wrapper（含 skill 指向、不含 workflow 全文）
  > Command: `for f in explore propose apply archive; do echo "== $f =="; wc -l < claude/commands/opsx/$f.md; grep -c "Use the \`openspec-" claude/commands/opsx/$f.md; done`
  > Expected: 每個檔案行數 ≤ 20，且各含 1 行 skill 指向（grep -c 輸出 1）
- [x] T2 commands 目錄只剩 4 個核心檔案
  > Command: `ls claude/commands/opsx/ | sort | tr '\n' ' '`
  > Expected: `apply.md archive.md explore.md propose.md `（恰好 4 檔，無其他）
- [x] T3 skills 目錄只剩 7 個 openspec-* skills
  > Command: `ls -d claude/skills/openspec-*/ | sed 's|claude/skills/||;s|/$||' | sort | tr '\n' ' '`
  > Expected: `openspec-apply-change openspec-archive-change openspec-code-review openspec-explore openspec-propose openspec-sync-specs openspec-tdd-verify `（恰好 7 個）
- [x] T4 保留的 skills 無 dangling cross-reference
  > Command: `grep -rn "openspec-continue-change\|openspec-new-change\|openspec-ff-change\|openspec-onboard\|openspec-verify-change\|openspec-bulk-archive-change\|/opsx:new\|/opsx:continue\|/opsx:ff\|/opsx:onboard\|/opsx:sync\|/opsx:verify\|/opsx:tdd-verify\|/opsx:re-verify\|/opsx:bulk-archive" claude/skills/openspec-apply-change/ claude/skills/openspec-archive-change/ claude/skills/openspec-explore/ claude/skills/openspec-propose/ claude/skills/openspec-tdd-verify/ claude/skills/openspec-code-review/ claude/skills/openspec-sync-specs/`
  > Expected: 無輸出（exit code 1，零匹配）
- [x] T5 總行數符合瘦身目標
  > Command: `wc -l claude/commands/opsx/*.md claude/skills/openspec-apply-change/SKILL.md claude/skills/openspec-archive-change/SKILL.md claude/skills/openspec-code-review/SKILL.md claude/skills/openspec-explore/SKILL.md claude/skills/openspec-propose/SKILL.md claude/skills/openspec-sync-specs/SKILL.md claude/skills/openspec-tdd-verify/SKILL.md | tail -1`
  > Expected: 總計 ≤ 1200 行（原 ~4200 行，約 -70% 以上）
- [x] T6 wrapper 指向的 skill 檔案皆存在
  > Command: `for s in openspec-explore openspec-propose openspec-apply-change openspec-archive-change; do test -f claude/skills/$s/SKILL.md && echo "$s OK"; done`
  > Expected: 4 行輸出，全部 `OK`
