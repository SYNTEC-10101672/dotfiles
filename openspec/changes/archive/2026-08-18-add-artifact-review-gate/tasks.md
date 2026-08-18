# Tasks: add-artifact-review-gate

## 1. 新增 openspec-artifact-review skill

- [x] 1.1 建立 `claude/skills/openspec-artifact-review/SKILL.md`：YAML frontmatter（`name: openspec-artifact-review`，description 涵蓋「propose 完成後審查 change artifacts」觸發時機）+ 英文 body，審查準則要素以 `openspec/changes/add-artifact-review-gate/specs/artifact-review-gate/spec.md` 的 Requirements 為準（blocker-only、approval bias、max 3 issues、reference 驗證、可執行性、anti-patterns 條列），並擴充 OpenSpec 檢查：delta spec 格式（`## ADDED Requirements` 等 section header、`### Requirement:`、`#### Scenario:` WHEN/THEN）、tasks.md `## Tests` 的 T\* `> Command:` / `> Expected:` 契約（缺件或無豁免理由為 blocker）、proposal / design / specs / tasks 相互矛盾。→ T1
- [x] 1.2 同檔案加入流程段落：input 為 `openspec/changes/<name>/` 目錄（讀 proposal.md、design.md、tasks.md、specs/ 全部）；每次 invoke 從 disk 重讀、前次 verdict 不約束本輪；read-only 約束（MUST NOT 寫入、編輯、刪除任何檔案，修訂由主 AI 執行）；verdict 輸出格式為 `[OKAY]` / `[ITERATE]` / `[REJECT]`（各附 Summary，ITERATE / REJECT 附 max 3 issues）；spawn 指引：brief 全文自足於 skill、spawn 一般 agent、不指定 OmO `subagent_type`。→ T1, T5

## 2. 改 openspec-propose 的 gate 呼叫

- [x] 2.1 修改 `claude/skills/openspec-propose/SKILL.md` step 8（`<!-- CUSTOM: momus-plan-gate -->` 區塊）：以 invoke `openspec-artifact-review` skill 取代 `task(subagent_type="momus", ...)`；verdict 處理改為 — `[OKAY]` 進 Output、`[ITERATE]` 修訂 flagged artifacts 後重新送審（自動修復最多 2 輪，第 3 次未通過停止並向使用者呈現問題）、`[REJECT]` 直接向使用者呈現；區塊 marker 更名為反映新 gate（如 `artifact-review-gate`）。→ T2, T3
- [x] 2.2 清除 `claude/skills/openspec-propose/SKILL.md` 全檔 momus 字樣：step 4.5 的「pass through the Momus gate」改為「pass through the artifact review gate」，其餘引用一併更新。→ T2

## Tests

- [x] T1: 新 skill 存在且含 verdict 詞彙
  > Command: test -f claude/skills/openspec-artifact-review/SKILL.md && grep -c '\[OKAY\]' claude/skills/openspec-artifact-review/SKILL.md
  > Expected: 指令 exit 0，grep 計數 ≥ 1

- [x] T2: openspec-propose 無 momus 殘留
  > Command: grep -in momus claude/skills/openspec-propose/SKILL.md
  > Expected: 無輸出（grep exit code 1）

- [x] T3: openspec-propose verdict 詞彙對齊三值
  > Command: grep -cE '\[(OKAY|ITERATE|REJECT)\]' claude/skills/openspec-propose/SKILL.md
  > Expected: 輸出 ≥ 3

- [x] T4: skills 目錄符合 8-skill 保留清單
  > Command: ls -d claude/skills/openspec-*/ | wc -l
  > Expected: 輸出 8

- [x] T5: 新 skill body prose 為英文（無 CJK 字元）
  > Command: grep -P -c '[\x{4e00}-\x{9fff}]' claude/skills/openspec-artifact-review/SKILL.md; test $? -eq 1
  > Expected: 指令 exit 0（grep 計數 0、找不到 CJK 字元）
