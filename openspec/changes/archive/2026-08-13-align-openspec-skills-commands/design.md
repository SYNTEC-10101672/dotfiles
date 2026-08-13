## Context

這次 change 動的是 `claude/` 下三組成對的 skill/command 檔案：

| Pair | Command 檔案 | Skill 檔案 |
|---|---|---|
| continue | `claude/commands/opsx/continue.md`（114 行） | `claude/skills/openspec-continue-change/SKILL.md`（118 行） |
| explore | `claude/commands/opsx/explore.md`（173 行） | `claude/skills/openspec-explore/SKILL.md`（288 行） |
| archive | `claude/commands/opsx/archive.md`（157 行） | `claude/skills/openspec-archive-change/SKILL.md`（114 行） |

**Frontmatter skip offset**（`openspec-skill-command-parity` spec 的 audit diff command 會用）：
- Command 檔案：frontmatter 占 line 1–5，body 從 line 6 開始 → audit 用 `tail -n +6`
- Skill 檔案：frontmatter 占 line 1–9，body 從 line 10 開始 → audit 用 `tail -n +10`

**Literal format token**（由 `openspec/specs/openspec-tdd-task-format/` 定義；周圍 prose 翻譯成英文時，這些 token 以原貌保留）：
- Section ID：`## 測試`、`## 實作`
- Field label：`> 指令：`、`> 預期：`
- Cross-reference marker：`（→ T<n>）`

**每個 drift 的 canonical side**（在下方 Decisions 決定，記在這裡讓 tasks 不必重述）：
- continue 格式說明 → SKILL 是 canonical，port 到 command
- explore entry-point 範例 → SKILL 是 canonical，port 到 command
- archive output template → COMMAND 是 canonical，port 到 skill
- archive AskUserQuestion → SKILL 是 canonical，把 command 對齊

**Extension drifts**（T7 audit 發現，記在 tasks.md section 3）：
- explore command 的 change-name hint → port 到 skill（1 行）
- explore skill 的 `## What We Figured Out` summary template → port 到 command（8 行）

**這次 change 用得到的 `write-great-skills` 原則**（完整定義在 `claude/skills/writing-great-skills/SKILL.md`）：
- **Single source of truth**：一個檔案內每個 meaning 只有一個權威位置
- **No-op test**：每個 sentence 都要能改變 model 的 default 行為 — 改不了的刪掉
- **Duplication**：同一個 meaning 出現在多處要 collapse
- **Completion criterion**：可檢查 + enumerative — 「列出的每個 format token 都保留」而不是「format token 保留」
- **Positive phrasing**：敘述目標行為；避免 negation

## Goals / Non-Goals

**Goals:**
- 消除三組成對檔案（continue、explore、archive）之間四個已記錄的 drift
- 建立可重現、確定性的 parity audit 程序（具體 diff 指令 + 客觀 drift 判定標準）
- 在 porting 過程中套用 `write-great-skills` pruning 原則，避免 port 目的地累積 sediment 或 duplication
- 把 OpenSpec task-format 合約 token（`## 測試`、`## 實作`、`> 指令：`、`> 預期：`、`（→ T<n>）`）以 literal identifier 保留 — 它們屬於 `openspec/specs/openspec-tdd-task-format/`，不是 prose

**Non-Goals:**
- 把成對檔案合併成單一實體 source（兩個檔案維持，我們維護 parity，不 merge）
- 把 literal format token 翻譯成英文（它們是 format ID，不是 prose）
- 補一個 `opsx/code-review.md` command（`code-review` skill 沒有對應的 command — 列為已知缺口，這次不處理）
- 補 `re-verify` 的 skill（也是已知缺口，不在 scope 內）
- 改 `openspec-tdd-task-format/`、`openspec-code-review/` 或任何其他既有 spec

## Decisions

### Decision 1：每個 drift 選一個 canonical side — 用已經有正確內容的那邊

每個 drift 都有一邊已經有正確內容、另一邊缺。我們從 canonical side port 到 drifting side，而不是兩邊都重寫。

| Drift | Canonical | Drifting | 理由 |
|---|---|---|---|
| continue 格式說明 | `skills/openspec-continue-change/SKILL.md`（line 105） | `commands/opsx/continue.md`（line 101） | Skill 已經符合 CLAUDE.md mandate；command 是違反的那邊 |
| explore entry-point 範例 | `skills/openspec-explore/SKILL.md`（line 146–249） | `commands/opsx/explore.md`（缺） | Skill 有比較豐富的內容；command 是閹割版 |
| archive output template | `commands/opsx/archive.md`（line 103–149） | `skills/openspec-archive-change/SKILL.md`（缺） | Command 有 template；skill 是無聲的那邊 |
| archive AskUserQuestion | `skills/openspec-archive-change/SKILL.md`（line 37, 48） | `commands/opsx/archive.md`（line 33, 44） | Skill 有明確 mandate 工具；command 模糊 |

**考慮過的替代方案**：
- _兩邊都用 `write-great-skills` 從零重寫_：拒絕。沒 audit 過的內容會回歸風險高；canonical side 已經通過前次 audit。
- _選短的那邊、把長的修短_：拒絕。會丟資訊；drift 顯示長的那邊有值得保留的內容（entry-point 範例、output template）。

### Decision 2：Porting 要套 `write-great-skills` pruning，不是 verbatim copy

從 canonical 移到 drifting 時，agent SHALL 套用 `write-great-skills` 原則（no-op test、collapse duplication、positive phrasing、sharpen completion criterion）。這樣可以避免 sediment 累積在目的地，並確保 ported 內容有賺到它的位置。

具體來說：
- 對每句 ported sentence 跑 no-op test；失敗的整句刪掉，不要只刪幾個字
- Collapse 目的地已經有的、會被 port 加劇的 duplication
- 把模糊的 completion criterion（「描述格式」）換成可檢查的（「列出每個 format token：`## 測試`、`## 實作`、`> 指令：`、`> 預期：`、`（→ T<n>）」）
- 用正面語氣（「mandate `AskUserQuestion`」）而非否定（「不要用 generic prompt」）

**考慮過的替代方案**：
- _Verbatim copy_：拒絕。會把 canonical side 既有的 sediment 一起帶過去；浪費 sharpen 目的地的機會。
- _從零重寫、忽略 source_：拒絕。維護者沒重新推導過的內容會有遺失風險。

### Decision 3：Audit 程序是確定性 diff，不是 LLM 判斷

Parity audit SHALL 是具體的 shell 指令（skip frontmatter）加上客觀的 drift 判定標準。不接受「問 agent 看起來有沒有對齊」。

每組 pair 的 audit 指令：
```bash
diff <(tail -n +6 claude/commands/opsx/<name>.md) <(tail -n +10 claude/skills/openspec-<name>-change/SKILL.md)
```

Drift 嚴重度分類：
- **ALIGNED**：diff 只顯示 frontmatter 差異（已被 `tail` offset 排除）與 cross-reference style 差異（`/opsx:<peer>` ↔ `openspec-<peer>-change`）
- **DRIFTED**：diff 顯示 missing section、missing format spec、missing structured template，或超出上述兩類可接受項的任何 body content delta

Spec 裡的 10-line threshold 是經驗值 — 若某組 pair 的 body diff（排除兩類可接受項後）超過 10 行，即使沒有具名 drift 也要調查。

**考慮過的替代方案**：
- _LLM-based audit（「讀兩個檔案判斷」）_：拒絕。不可重現；依 model 與 prompt 變動。
- _只看結構 diff（行數）_：拒絕。會漏掉小但高影響的 drift（例如 continue 那條漏掉格式說明的單行）。

### Decision 4：Literal format token 以 ID 保留，body prose 用英文

Porting 或重寫 body section 時，OpenSpec task-format 的 literal token（`## 測試`、`## 實作`、`> 指令：`、`> 預期：`、`（→ T<n>）`）SHALL 在 code span 或 code block 中原貌出現。這些 token 是 `openspec/specs/openspec-tdd-task-format/` 定義的合約一部分。翻譯它們會破壞 tasks.md parsing 與 `openspec-tdd-verify` workflow。

周圍的描述 prose SHALL 用英文。`skills/openspec-continue-change/SKILL.md:105` 目前的中文描述句（「使用 `## 測試` / `## 實作` 雙區塊格式…」）SHALL 改寫成英文 prose，format token 保留原貌。

**考慮過的替代方案**：
- _把 format token 翻成英文（`## Tests`、`## Implementation`）_：拒絕。會破壞 `openspec-tdd-verify`（它 pattern-match 中文 ID）；也違反 CLAUDE.md 明文規定要用 `## 測試` / `## 實作`。
- _把描述 prose 留中文_：拒絕。這次 session 中使用者明確說「應該都是要寫英文」。

### Decision 5：Parity edit 不動 frontmatter

Parity edit SHALL 不動任一邊的 frontmatter。兩種檔案類型的 frontmatter 各自有不同目的：

- Command frontmatter：`name: "OPSX: <Display>"`、`description`、`category: Workflow`、`tags: [...]` — 驅動 `/opsx:<name>` slash-command discovery 與 OpenCode UI grouping
- Skill frontmatter：`name: openspec-<name>`、`description`、`license: MIT`、`compatibility`、`metadata.{author,version,generatedBy}` — 驅動 `load_skills=["openspec-<name>"]` matching

為了「對齊」去改 frontmatter，要嘛破壞 slash-command discovery，要嘛破壞上游 version tracking，而且沒有 parity 好處（frontmatter 不是 user 看到的 operational guidance）。

**考慮過的替代方案**：
- _標準化 frontmatter_：拒絕。理由如上。
- _兩邊 mirror frontmatter 欄位_：拒絕。每種檔案類型有它需要的 frontmatter。

## Risks / Trade-offs

- **[Risk] 10-line audit threshold 是經驗值；可能誤判可接受的風格差異，或漏掉小但高影響的 drift** → _Mitigation_：次要標準（「任何 missing section / format spec / template 不論行數都算 DRIFTED」）抓住高影響的小 drift。Threshold 未來有 false positive 累積時可調。
- **[Risk] 用 `write-great-skills` pruning porting 可能回歸維護者沒 audit 過的 canonical side 內容** → _Mitigation_：pruning 只套用在 ported content（drifting side 的新增）；canonical side 只動 AskUserQuestion 對齊（是一個字替換），不廣泛重寫 canonical content。
- **[Trade-off] 兩個實體檔案 per workflow 維持，parity 手動維護** → _Accepted_：替代方案（單一 source + 生成）需要一個不存在的 build step；parity 維護成本比導入並維護 generator 低。
- **[Trade-off] `code-review`、`re-verify` 缺口（單邊檔案）有記錄但這次不補** → _Accepted_：補這些缺口需要獨立設計決策（`code-review` 該有 command 嗎？`re-verify` 該有 skill 嗎？），跟 parity 無關，應該另開 proposal。

## Migration Plan

無程式碼 migration。順序：

1. 實作四個 alignment task（見 `tasks.md`）
2. 每個 task 用對應的 T* test 驗證（diff audit + content presence 檢查）
3. 跑 `openspec-code-review`（按 CLAUDE.md mandate）
4. Archive 這個 change

Rollback：`git revert` change commit。沒有 runtime state 要還原。

## Open Questions

無 blocking。四個 drift 與其 canonical side 已決定；audit 程序完全指定；format-token 保留規則無歧義。
