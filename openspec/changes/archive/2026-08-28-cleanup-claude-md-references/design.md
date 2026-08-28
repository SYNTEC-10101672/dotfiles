# Design: cleanup-claude-md-references

## Context

- 全域指示檔（`claude/CLAUDE.md`，部署於 `~/.claude/CLAUDE.md`）的規則屬 ambient 規則（`CONTEXT.md` 詞彙）：system prompt 永遠已載入。
- 編輯依據 `writing-for-agents` skill 的 levers：no-op test、single source of truth、negation → positive、leading words 對齊。
- 上游參考：`mattpocock/skills` 的 `engineering/code-review/SKILL.md` — Standards 軸來源定義為 repo documented standards + 固定 smell baseline，不含任何 system prompt。
- 本 change 是「先清理、後搬遷」序列的第一步；搬遷（AGENTS.md 改名、目錄遷移）由後續獨立 change 處理。

## Goals / Non-Goals

**Goals:**

- skills 與 commands 內容不再引用 `CLAUDE.md`（檔名或路徑），`writing-for-agents` 的文件類型詞彙除外
- `openspec-code-review` 的 Standards 軸來源與上游設計對齊
- `openspec-apply-change` 的 severity 用語與 `openspec-code-review` 修改後的語言一致（leading words 跨文件對齊）
- 每處編輯遵循一條對應的 writing-for-agents lever（見 Decisions 表）

**Non-Goals:**

- 不搬移任何檔案（git mv、Makefile、symlinks 屬於後續搬遷 change）
- 不改名 `CLAUDE.md` → `AGENTS.md`（同上）
- 不改 `writing-for-agents/SKILL.md`（CLAUDE.md 為文件類型詞彙）
- 不在 skill 內重抄 ambient 規則作為「替代」（那只是換一種形式的 duplication）
- 不處理 `~/.claude/` compat 讀取、`oh-my-openagent.json`、`env.example` 等搬遷議題

## Decisions

| # | 處置 | 對應 lever | 理由 |
|---|---|---|---|
| D1 | `openspec-code-review/SKILL.md:33` 刪除 `~/.claude/CLAUDE.md` 標準來源行 | no-op test（system prompt 已載，引用不增加檢查力）+ 上游對齊 | 審查標準應為 repo documented contract，非 generation-time 約束；「最小變更」由 Spec 軸 scope creep 涵蓋 |
| D2 | 同檔 `:3` frontmatter description："CLAUDE.md code standards" → "documented repo standards" | description 是 context pointer，wording 決定 invocation 可靠性 | 與 D1 一致；pointer 字眼必須反映實際來源 |
| D3 | 同檔 `:58` brief 括號："CLAUDE.md code standards section content" → "the standards-source files found in step 3" | leading words 對齊 | sub-agent brief 需自足且與 step 3 清單同語言 |
| D4 | 同檔 `:61` brief body："(a) violations of CLAUDE.md code standards (cite rule)" → "(a) violations of documented repo standards (cite file + rule)" | 同上 | 引用來源改為 file + rule，符合 repo documented 標準的引用形態 |
| D5 | `tutoring/SKILL.md` 刪除整個 "Integration with User Settings" section（`:367` heading 至 `## Example: Full Tutoring Response` 前） | single source of truth（重抄 = duplication，會 stale）+ no-op | 該 section 三組規則全為 ambient 規則的重複陳述 |
| D6 | `commit.md:28` 刪除「，符合 CLAUDE.md 規範」出處註記，保留「是否使用英文註解」檢查項 | 環境是 source of truth，註記是會 stale 的 cache | check 本身已自足，出處註記零功能 |
| D7 | `commit.md:32` 刪除對比參考清單的「CLAUDE.md 的專案規範」條目 | 同 D1 理由（system prompt 非比對標準） | 前兩條（同目錄檔案、專案同類型檔案）才是正確比對源；repo 若有 documented standards，已由 ambient 載入 |
| D8 | `eli5.md` 改寫：開頭改「本 session 啟用 ELI5 模式（疊加於既有規則，衝突時以此為準）：」；結尾改「檔案路徑、指令、config 值維持原樣精確。」 | negation → positive；live content 保留 | 「衝突時以此為準」是必要裁決（ELI5 的「其餘省略」與全域「大詞一句話解釋」有真衝突），須正面陳述；精確要求內文明示 |
| D9 | `openspec-apply-change/SKILL.md:104`："(violates CLAUDE.md / major Fowler smell)" → "(violates a documented repo standard / major Fowler smell)" | leading words 跨文件對齊 | 不改則兩個 skill 對同一 severity 使用不同語言 |
| D10 | Delta spec 調和：`openspec/specs/openspec-code-review/spec.md` 既有三條 requirement 內文要求 CLAUDE.md 作為 Standards 來源（`:21`、`:62`、`:77` 要求 + `:111` scenario），與本 change 矛盾 — 補 `specs/openspec-code-review/spec.md` delta：兩條 MODIFIED（內文字眼）、一條 REMOVED + ADDED（requirement 名稱本身含 CLAUDE.md，無法原地改，REMOVED 附 Reason/Migration、ADDED 給新 requirement 含 severity 對齊 scenario） | delta spec 與主 spec 體系一致 | archive 後 spec corpus 不得自相矛盾；其餘 8 個含 CLAUDE.md 字眼的 specs 均規範「CLAUDE.md 本身內容」（搬遷 change 領域）或已與本 change 對齊（`commit-rules-placement:34` 本就要求 commit.md 不引用 CLAUDE.md），非本 change 範圍。附註：delta 格式只覆蓋 Requirements，主 spec `:3` header prose「Standards 軸檢查 CLAUDE.md 程式碼規範」需在 archive sync 時一併更新 |

## Risks / Trade-offs

- [Standards 軸失去全域「程式碼規範」檢查（註解英文、最小變更）] → 接受：generation-time 的 system prompt 已約束寫作行為；「最小變更」的 diff 面向由 Spec 軸 scope creep 條目涵蓋。此為與上游設計一致的刻意取捨。
- [sub-agent 若未注入全域 AGENTS.md，遺失規則] → 接受：原引用形式（叫 orchestrator 讀檔貼內容）已刪，若未來某軸需要規則，正確做法是內文 paste（brief 已自足），非恢復檔案引用。
- [eli5 疊加語意改寫若遺漏「衝突時以此為準」] → T3 驗證字串存在。

## Migration Plan

文件內容變更，無部署步驟。symlink 已指向這些檔案，存檔即生效於新 session。驗證見 tasks.md T1–T5。
