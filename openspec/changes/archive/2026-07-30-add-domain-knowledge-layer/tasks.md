## 測試

### T1: grill-with-docs SKILL.md 存在且與 upstream 一致
> 指令：比對 `/home/syntec/personal/dotfiles/claude/skills/grill-with-docs/SKILL.md` 與 upstream `https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md`
> 預期：兩者內容完全相同——frontmatter 含 `name: grill-with-docs`、`description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.`、`disable-model-invocation: true`；body 為 `Run a \`/grilling\` session, using the \`/domain-modeling\` skill.`

### T2: grill-with-docs agents/openai.yaml 存在且 policy 正確
> 指令：讀取 `/home/syntec/personal/dotfiles/claude/skills/grill-with-docs/agents/openai.yaml`
> 預期：包含 `interface.display_name: "Grill with Docs"`、`interface.short_description: "Grill a design and write its docs"`、`policy.allow_implicit_invocation: false`

### T3: CLAUDE.md 包含 CONTEXT.md 消費規則
> 指令：讀取 `/home/syntec/personal/dotfiles/claude/CLAUDE.md`，檢查是否含獨立的領域知識消費章節
> 預期：存在一個獨立章節（非 OpenSpec 規範的一部分），提及 `CONTEXT.md`，且規則涵蓋三點：(1) 開工前讀取 repo 根目錄的 `CONTEXT.md`；(2) 輸出使用其詞彙，不漂移到同義詞；(3) 檔案不存在則靜默繼續，不報錯、不建議建立

### T4: grill-with-docs 透過 symlink 即時可見
> 指令：執行 `ls ~/.claude/skills/grill-with-docs/`
> 預期：透過 `claude-config-symlink` 的 symlink 看到 `SKILL.md` 與 `agents/` 目錄，不需手動重啟

### T5: 既有 4 個 mattpocock skill 未被修改（回歸驗證）
> 指令：在 `/home/syntec/personal/dotfiles/` 執行 `git diff --stat -- claude/skills/grill-me/ claude/skills/grilling/ claude/skills/domain-modeling/ claude/skills/writing-great-skills/`
> 預期：無輸出（`grill-me`、`grilling`、`domain-modeling`、`writing-great-skills` 4 個既有 skill 的檔案均未被觸碰）

## 實作

- [x] 1.1 新增 `/home/syntec/personal/dotfiles/claude/skills/grill-with-docs/SKILL.md`，vendor 自 upstream `https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md`，內容含 frontmatter（`name: grill-with-docs`、`description`、`disable-model-invocation: true`）與 body（`Run a /grilling session, using the /domain-modeling skill.`）（→ T1）
- [x] 1.2 新增 `/home/syntec/personal/dotfiles/claude/skills/grill-with-docs/agents/openai.yaml`，vendor 自 upstream，含 `interface.display_name: "Grill with Docs"`、`interface.short_description: "Grill a design and write its docs"`、`policy.allow_implicit_invocation: false`（→ T2）
- [x] 1.3 確認 symlink 生效：執行 `ls ~/.claude/skills/grill-with-docs/` 顯示 `SKILL.md` 與 `agents/`（→ T4）
- [x] 2.1 修改 `/home/syntec/personal/dotfiles/claude/CLAUDE.md`，在 `## OpenSpec 規範` 之後新增 `## 領域知識規範` 章節，涵蓋三點規則：(1) 開工前若 repo 根目錄有 `CONTEXT.md` 則先讀取；(2) 輸出使用其詞彙不漂移；(3) 不存在則靜默繼續。另含 `CONTEXT-MAP.md` 多 context 讀取指示（→ T3）
