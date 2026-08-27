## Implementation

- [x] T1: 改寫 `claude/skills/openspec-explore/SKILL.md` L14 寫檔白名單
  將 L14 的 "You MAY create OpenSpec artifacts (proposals, designs, specs) if the user asks—that's capturing thinking, not implementing." 改為白名單制文字：explore mode 僅可寫入 `openspec/changes/**` 與經 domain-modeling 程序 resolved 的 `CONTEXT.md`；任何其他寫入請求（含使用者口頭要求直接改 code）一律回覆引導至 `/opsx:propose`，並保留「使用者要求實作時提醒離開 explore mode」的原有意涵。

- [x] T2: 改寫 `claude/skills/openspec-explore/SKILL.md` L291 domain vocabulary 條目
  將 "**Do capture domain vocabulary** - When a term gets a precise agreed definition, write it into the project's `CONTEXT.md` right away (format per `/domain-modeling`'s CONTEXT-FORMAT.md; create the file lazily if absent)" 改為：當詞彙定義 crystallize 時，invoke `domain-modeling` skill 走挑戰程序（challenge fuzzy terms → scenario 逼出邊界 → resolved）；resolved 後才以 domain-modeling skill 的 `CONTEXT-FORMAT.md` 格式寫入 `CONTEXT.md`（檔案不存在時 lazily 建立）。若環境不支援 invoke skill，至少先讀 `domain-modeling` skill 的 `SKILL.md` 與 `CONTEXT-FORMAT.md`（與本 skill 同 skills 目錄）再寫。

- [x] T3: 同步 `claude/skills/openspec-explore/SKILL.md` Guardrails 段
  Guardrails 的 "**Don't implement**" 條目改為列明白名單（`openspec/changes/**`、經程序的 `CONTEXT.md`）；"**Do capture domain vocabulary**" 條目同步 T2 的程序指示，移除 "right away"。

- [x] T4: 在 `claude/skills/openspec-explore/SKILL.md`「Handling Different Entry Points」段新增 few-shot 反例
  新增一組對話範例（與既有範例同格式）：user 說「那你直接改一改吧」（Just go ahead and change it）→ 回應示範：說明這是實作、超出 explore 範圍，引導執行 `/opsx:propose` 將討論結論轉為 change proposal。

- [x] T5: 改寫 `claude/skills/openspec-propose/SKILL.md` L120-121 domain vocabulary 條目
  將 "**Domain vocabulary → write into CONTEXT.md immediately**: When a lookup or artifact-writing discussion pins down a domain term, write it into the project's `CONTEXT.md` right away (format per `/domain-modeling`'s CONTEXT-FORMAT.md; create the file lazily if absent). Do not batch terms to the end of the session." 改為與 T2 相同的程序指示：詞彙 crystallize 時 invoke `domain-modeling` skill（或先讀其 SKILL.md 與 CONTEXT-FORMAT.md），經挑戰程序 resolved 後才寫入。

## Tests

- [x] T6: grep 驗證舊字眼消除
  > Command: grep -nE 'right away|immediately|Do not batch' claude/skills/openspec-explore/SKILL.md claude/skills/openspec-propose/SKILL.md
  > Expected: 兩檔案中所有匹配行均不含 `CONTEXT.md` 寫入指示語境（若無匹配則 exit code 1 為通過）

- [x] T7: grep 驗證 explore 白名單與 capturing-thinking 例外移除
  > Command: grep -n "capturing thinking" claude/skills/openspec-explore/SKILL.md; grep -nE 'openspec/changes/\*\*|CONTEXT\.md' claude/skills/openspec-explore/SKILL.md
  > Expected: 第一個 grep 無輸出（exit 1）；第二個 grep 在寫檔規範段落（L14 附近與 Guardrails 段）出現白名單字眼

- [x] T8: grep 驗證 domain-modeling 程序指示存在
  > Command: grep -n 'domain-modeling' claude/skills/openspec-explore/SKILL.md claude/skills/openspec-propose/SKILL.md
  > Expected: 兩檔案的 domain vocabulary 條目均含 invoke `domain-modeling` skill（或先讀 SKILL.md + CONTEXT-FORMAT.md）的程序指示

- [x] T9: grep 驗證 few-shot 反例存在
  > Command: grep -n 'opsx:propose' claude/skills/openspec-explore/SKILL.md
  > Expected: 至少一個匹配位於「Handling Different Entry Points」段的對話範例中，示範拒絕直接實作並引導 propose
