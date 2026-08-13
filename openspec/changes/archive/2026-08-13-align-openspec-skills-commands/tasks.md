## 測試

### T1 continue pair: format spec present in both files

> 指令：
> ```bash
> grep -c "## 測試" claude/commands/opsx/continue.md
> grep -c "## 實作" claude/commands/opsx/continue.md
> grep -cE ">( 指令|預期)：" claude/commands/opsx/continue.md
> grep -c "（→ T" claude/commands/opsx/continue.md
> ```
>
> 並用 `diff <(tail -n +6 claude/commands/opsx/continue.md) <(tail -n +10 claude/skills/openspec-continue-change/SKILL.md) | grep -E "測試|實作|指令：|預期：|（→ T" ` 檢查兩邊都提到這些 token。

> 預期：
> `claude/commands/opsx/continue.md` 的 body 含一段英文描述，明確列出 `## 測試` / `## 實作` 雙區塊格式，並在 code span 或 code block 中保留字面 token：`> 指令：`、`> 預期：`、`（→ T<n>）`。語意與 `claude/skills/openspec-continue-change/SKILL.md` 既有的格式說明等價。Audit diff 不再把「缺少 format spec」列為 drift。

---

### T2 explore pair: entry-point examples present in both files

> 指令：
> ```bash
> grep -c "Handling Different Entry Points" claude/commands/opsx/explore.md
> for p in "vague idea" "specific problem" "stuck mid-implementation" "compare options"; do
>   echo "--- $p ---"
>   grep -c "$p" claude/commands/opsx/explore.md
> done
> ```

> 預期：
> `claude/commands/opsx/explore.md` 的 body 含 `## Handling Different Entry Points` section（或等價標題），涵蓋 4 種 entry pattern：vague idea / specific problem / stuck mid-implementation / compare options，每種都有示意圖（ASCII / unicode diagram）範例，語意等價於 `claude/skills/openspec-explore/SKILL.md` lines 146–249 的內容。Audit diff 不再把這段缺失列為 drift。

---

### T3 archive pair: three output templates present in both files

> 指令：
> ```bash
> for t in "Output On Success (No Delta Specs)" "Output On Success With Warnings" "Output On Error (Archive Exists)"; do
>   echo "--- $t ---"
>   grep -c "$t" claude/skills/openspec-archive-change/SKILL.md
>   grep -c "$t" claude/commands/opsx/archive.md
> done
> ```

> 預期：
> `claude/skills/openspec-archive-change/SKILL.md` 的 body 含全部三個 output template heading（`Output On Success (No Delta Specs)`、`Output On Success With Warnings`、`Output On Error (Archive Exists)`），每個 template 的 markdown 結構（包含 `## Archive Complete` / `## Archive Failed` 等 literal heading 與 `**Change:**`、`**Schema:**`、`**Archived to:**`、`**Specs:**` 等欄位）等價於 `claude/commands/opsx/archive.md` lines 103–149。Audit diff 不再把 templates 缺失列為 drift。

---

### T4 archive pair: AskUserQuestion mandated in both files

> 指令：
> ```bash
> grep -nE "(Prompt user for confirmation|AskUserQuestion)" claude/commands/opsx/archive.md
> grep -nE "AskUserQuestion" claude/skills/openspec-archive-change/SKILL.md
> ```

> 預期：
> `claude/commands/opsx/archive.md` 不再出現 `Prompt user for confirmation to continue` 字樣；改為明確 mandate `AskUserQuestion` tool（與 `claude/skills/openspec-archive-change/SKILL.md` lines 37, 48 一致）。兩個 confirmation prompt（pre-edit 位於 archive.md lines 33, 44）都對齊。

---

### T5 frontmatter byte-identity across all 5 edited files

> 指令：
> ```bash
> for f in claude/commands/opsx/continue.md \
>          claude/skills/openspec-continue-change/SKILL.md \
>          claude/commands/opsx/explore.md \
>          claude/commands/opsx/archive.md \
>          claude/skills/openspec-archive-change/SKILL.md; do
>   echo "--- $f ---"
>   git diff "HEAD:$f" "$f" | grep -E "^[+-](name|description|category|tags|license|compatibility|metadata|  (author|version|generatedBy)):" || echo "(no frontmatter changes)"
> done
> ```

> 預期：
> 全部 5 個被編輯檔案的 frontmatter 區塊（command: lines 1–5, skill: lines 1–9）與 pre-edit 狀態 byte-identical。Git diff 對 frontmatter 欄位（`name`, `description`, `category`, `tags`, `license`, `compatibility`, `metadata.*`）零輸出。

---

### T6 literal format tokens preserved as-is

> 指令：
> ```bash
> for tok in "## 測試" "## 實作" "> 指令：" "> 預期：" "（→ T"; do
>   echo "--- $tok ---"
>   grep -cF "$tok" claude/commands/opsx/continue.md
>   grep -cF "$tok" claude/skills/openspec-continue-change/SKILL.md
> done
> ```

> 預期：
> `claude/commands/opsx/continue.md` 與 `claude/skills/openspec-continue-change/SKILL.md` 對所有 5 個 literal token（`## 測試`、`## 實作`、`> 指令：`、`> 預期：`、`（→ T<n>）`）都回傳 ≥ 1（出現在 code span 或 code block 中）。Token 字面不變（沒有翻譯成 `## Tests`、`> Command:` 等）。

---

### T7 audit command classifies all 3 pairs as ALIGNED

> 指令：
> ```bash
> for pair in continue:continue-change explore:explore archive:archive-change; do
>   cmd="${pair%%:*}"; skill="${pair##*:}"
>   echo "=== $cmd ↔ $skill ==="
>   diff <(tail -n +6 "claude/commands/opsx/$cmd.md") \
>        <(tail -n +10 "claude/skills/openspec-$skill/SKILL.md") |
>     grep -vE "^[-+]" ||
>     echo "(no body content diff beyond acceptable categories)"
> done
> ```

> 預期：
> 對 continue / explore / archive 三個 pair 執行 audit diff 後，差異只剩兩類可接受項：(a) 兩邊 cross-reference style 差異（`/opsx:<peer>` ↔ `openspec-<peer>-change`）、(b) 邊殼用語差異。沒有 missing section / missing format spec / missing template / missing entry-point example。三個 pair 都分類為 `ALIGNED`。

---

## 實作

### 1. Port missing content (parallel-safe — different files)

- [x] 1.1 **continue pair (2 files)**: 
  - `claude/commands/opsx/continue.md`: ADD a paragraph describing the `## 測試` / `## 實作` dual-block tasks.md format. Write in English; preserve literal tokens (`## 測試`, `## 實作`, `> 指令：`, `> 預期：`, `（→ T<n>）`) inside code spans or code blocks. Semantic content equivalent to `claude/skills/openspec-continue-change/SKILL.md:105`.
  - `claude/skills/openspec-continue-change/SKILL.md`: REWRITE the existing Chinese descriptive sentence on line 105 ("使用 `## 測試` / `## 實作` 雙區塊格式…") to English prose. Literal tokens stay unchanged inside code spans (Decision 4 mandate).
  - Apply `write-great-skills` pruning on both edits: run no-op test on each ported sentence, collapse duplication, sharpen completion criterion to "list every format token". Do NOT edit frontmatter.（→ T1, T5, T6）

- [x] 1.2 `claude/commands/opsx/explore.md`: Port the "Handling Different Entry Points" section (4 entry patterns: vague idea / specific problem / stuck mid-implementation / compare options, each with ASCII diagram) from `claude/skills/openspec-explore/SKILL.md:146–249`. Apply `write-great-skills` pruning; preserve all 4 patterns (do not collapse). Do NOT edit frontmatter.（→ T2, T5）

- [x] 1.3 `claude/skills/openspec-archive-change/SKILL.md`: Port the three output templates (`Output On Success (No Delta Specs)`, `Output On Success With Warnings`, `Output On Error (Archive Exists)`) from `claude/commands/opsx/archive.md:103–149`. Preserve literal template headings and field labels (`## Archive Complete`, `## Archive Failed`, `**Change:**`, `**Schema:**`, `**Archived to:**`, `**Specs:**`, `**Warnings:**`). Apply `write-great-skills` pruning. Do NOT edit frontmatter.（→ T3, T5）

- [x] 1.4 `claude/commands/opsx/archive.md`: Replace the two `Prompt user for confirmation to continue` lines (pre-edit lines 33, 44) with explicit `Use **AskUserQuestion tool** to confirm user wants to proceed` phrasing, matching `claude/skills/openspec-archive-change/SKILL.md:37, 48`. Do NOT edit frontmatter.（→ T4, T5）

### 2. Verification

- [x] 2.1 Run the audit command from T7 against all 3 pairs. Manually classify any remaining diff as either (a) acceptable cross-reference style difference, (b) acceptable cosmetic wording, or (c) drift requiring return to step 1. Record the classification for each pair in the change's commit message.（→ T7）

### 3. Extension (out-of-scope drifts found during T7 audit, fixed in same change)

- [x] 3.1 `claude/skills/openspec-explore/SKILL.md`: ADD "If the user mentioned a specific change name, read its artifacts for context." after the openspec list block (matching `claude/commands/opsx/explore.md:97`).
- [x] 3.2 `claude/commands/opsx/explore.md`: REPLACE the 1-line summary ("When things crystallize...") with the full `## What We Figured Out` summary template block from `claude/skills/openspec-explore/SKILL.md`.
