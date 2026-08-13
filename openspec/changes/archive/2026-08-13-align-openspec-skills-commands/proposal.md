## Why

OpenSpec 每個 workflow 都出兩份成對 artifact：`claude/skills/openspec-<name>/SKILL.md`（給 subagent auto-load）與 `claude/commands/opsx/<name>.md`（給 user explicit 走 `/opsx:<name>`）。當這兩份 drift，兩條 invocation path 會 silently 產出不同結果：`/opsx:continue` 漏了 CLAUDE.md 強制規定的 `## 測試` / `## 實作` 格式說明、`/opsx:explore` 缺 entry-point 範例、`openspec-archive-change` skill 缺 `/opsx:archive` command 有的 structured output templates、confirmation 機制只有 skill 強制 `AskUserQuestion`。前次 audit 抓到四個具體 drift，需要修掉並把 pair-parity 原則 codify 成 spec，讓未來 audit 更省事。

## What Changes

- **continue pair 對齊**：把 `## 測試` / `## 實作` 雙區塊格式說明補進 `commands/opsx/continue.md`。兩個檔案都改用等價的英文 prose 描述格式（中文 section ID `## 測試` / `## 實作` 與 token `> 指令：`、`> 預期：`、`（→ T<n>）` 是 literal format identifier，不翻譯）。
- **explore pair 對齊**：把 "Handling Different Entry Points" section（4 種 entry pattern 含示意圖：vague idea / specific problem / stuck mid-implementation / compare options）從 `skills/openspec-explore/SKILL.md` port 進 `commands/opsx/explore.md`，讓兩條 invocation path 產出等價的探索 output。
- **archive pair 對齊（output templates）**：把三個 structured output template（`Output On Success (No Delta Specs)`、`Output On Success With Warnings`、`Output On Error (Archive Exists)`）從 `commands/opsx/archive.md` port 進 `skills/openspec-archive-change/SKILL.md`，讓 subagent 走 skill 時也會產出相同的 structured error reporting。
- **archive pair 對齊（confirmation tool）**：把 `commands/opsx/archive.md` 與 `skills/openspec-archive-change/SKILL.md` 都明確 mandate `AskUserQuestion` tool（目前只有 skill 這樣寫）。
- **所有被改動的 body 用英文**：這次 change 動到的每個 body section 都用英文撰寫。Format identifier（`## 測試`、`## 實作`、`> 指令：`、`> 預期：`、`（→ T<n>）`）以 literal token 保留 — 它們是 `openspec/specs/openspec-tdd-task-format/` 定義的格式合約，不是要翻譯的 prose。
- **Frontmatter 不動**：`name`、`description`、`category`、`tags`、`license`、`metadata.*` 兩邊都維持英文 — 這些欄位驅動 skill matching 與 slash-command discovery，改了會破壞 auto-load。

## Capabilities

### New Capabilities
- `openspec-skill-command-parity`: Codify 成對的 `skills/openspec-<name>/SKILL.md` 與 `commands/opsx/<name>.md` 必須行為對齊的合約。定義四個 alignment 軸（body content、cross-reference、confirmation UX、structured outputs）與 audit 程序。

### Modified Capabilities
<!-- 無。四個 drift 都是既有檔案內部的 content fix，沒有改 openspec-tdd-task-format、openspec-code-review 的 spec-level 行為。 -->

## Impact

- **編輯檔案（共 6 個）**：
  - `claude/commands/opsx/continue.md` — 新增 `## 測試` / `## 實作` 格式說明
  - `claude/skills/openspec-continue-change/SKILL.md` — 把 line 105 的中文描述句改寫成英文（Decision 4 mandate；literal token 保留）
  - `claude/commands/opsx/explore.md` — 新增 "Handling Different Entry Points" section 與 `## What We Figured Out` summary template（後者為 T7 audit 發現的 extension drift）
  - `claude/skills/openspec-explore/SKILL.md` — 補一行 change-name hint（T7 audit 發現的 extension drift）
  - `claude/commands/opsx/archive.md` — 把 2 行 `Prompt user for confirmation` 換成明確的 `AskUserQuestion` mandate
  - `claude/skills/openspec-archive-change/SKILL.md` — 新增 3 個 structured output template
- **不動的檔案**：無（原列為「不動」的 explore skill 後來補了 1 行 extension，已列入 tasks.md section 3）
- **程式碼無變更**：純 documentation/skill-content edits。
- **`/opsx:upgrade` 行為**：這次 change 完之後，6 個被編輯的檔案會被 `/opsx:upgrade` 的 diff step 偵測為 customized。未來上游更新會默認跳過這些檔案。這是預期行為 — 這些檔案現在帶有 project-specific 內容，超出 upstream baseline。
- **不破壞既有功能**：所有既有的 slash command（`/opsx:continue`、`/opsx:explore`、`/opsx:archive` 與 skill 自動註冊的 `/openspec-*`）都繼續可用。這次改動只增加內容、對齊用語，沒有改動 public interface。
- **CLAUDE.md 對齊**：這次 change 滿足 CLAUDE.md 既有 mandate — `tasks.md` 要用 `## 測試` / `## 實作` 雙區塊格式。原本只有 skill path 有強制；現在兩條 path 都有。
