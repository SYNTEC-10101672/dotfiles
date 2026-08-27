# Tasks: migrate-user-invoked-skills-to-commands

## Implementation

- [x] 1. 建立 `claude/commands/writing-fragments.md`
  - Frontmatter：`description: "Writing, explore: mine raw fragments, no structure yet."`、`argument-hint: [fragments-save-path]`
  - Body 第一行：`Fragments save path: $ARGUMENTS`
  - 之後照搬 upstream `skills/in-progress/writing-fragments/SKILL.md` 的 `<what-to-do>` 與 `<supporting-info>` 區塊（略過 skill frontmatter），內容不改
- [x] 2. 建立 `claude/commands/writing-beats.md`
  - Frontmatter：`description: Writing, exploit; assemble raw material into a journey of beats, grounding each term before a beat leans on it.`、`argument-hint: [raw material path]`
  - Body 第一行：`Raw material file: $ARGUMENTS`
  - 之後照搬 upstream `skills/in-progress/writing-beats/SKILL.md` 的 `<what-to-do>` 與 `<supporting-info>` 區塊，內容不改
- [x] 3. 建立 `claude/commands/writing-shape.md`
  - Frontmatter：`description: "Writing, exploit: shape raw material into an article, paragraph by paragraph."`、`argument-hint: [raw material path]`
  - Body 第一行：`Raw material file: $ARGUMENTS`
  - 之後照搬 upstream `skills/in-progress/writing-shape/SKILL.md` 的 `<what-to-do>` 與 `<supporting-info>` 區塊，內容不改
- [x] 4. 建立 `claude/commands/grill-me.md`
  - Frontmatter：`description: A relentless interview to sharpen a plan or design.`、`argument-hint: [topic to grill]`
  - Body 第一行：`Topic to grill: $ARGUMENTS`
  - 之後照搬 upstream `skills/productivity/grill-me/SKILL.md` 的 body（`Call the Skill tool with "grilling".`）
- [x] 5. 建立 `claude/commands/grill-with-docs.md`
  - Frontmatter：`description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.`、`argument-hint: [topic to grill]`
  - Body 第一行：`Topic to grill: $ARGUMENTS`
  - 之後照搬 upstream `skills/engineering/grill-with-docs/SKILL.md` 的 body（`Call the Skill tool twice, for "grilling" and "domain-modeling".`）
- [x] 6. 刪除 5 個 skill 目錄：`git rm -r claude/skills/writing-fragments claude/skills/writing-beats claude/skills/writing-shape claude/skills/grill-me claude/skills/grill-with-docs`（各含 `SKILL.md` 與 `agents/openai.yaml`）
- [x] 7. 執行 `make claude && make opencode` 後驗證 symlink 透通（見 Tests T1–T4）

（註 1：`.omo/plans/add-writing-skills.md` 是歷史 plan 文件，記錄當時的 vendor 計畫，不隨本變更修改。）
（註 2：實作時發現 upstream 在 2026-08-18 vendor 後有更新（writing 系列 em-dash 清理、grill 系列改為 Skill tool 措辭、grill-with-docs description 改提 ADR 與 glossary）。經使用者決策改抓最新 upstream — body 來源 = 遷移當下 live upstream main，非本地舊 snapshot。T7 的 live-URL 比對因此直接生效。）

## Tests

- [x] T1: 5 個 command 檔案存在於 repo
  > Command: `ls claude/commands/ | grep -E "writing-(fragments|beats|shape)|grill-(me|with-docs)" | sort`
  > Expected: 列出 `grill-me.md`、`grill-with-docs.md`、`writing-beats.md`、`writing-fragments.md`、`writing-shape.md` 共 5 行
- [x] T2: 舊 skill 目錄已移除、保留的 skills 完整
  > Command: `ls claude/skills/ | grep -E "grill|writing"`
  > Expected: 僅列出 `grilling`、`writing-for-agents`（無 `grill-me`、`grill-with-docs`、`writing-beats`、`writing-fragments`、`writing-shape`）
- [x] T3: Claude Code 部署透通
  > Command: `ls ~/.claude/commands/ | grep -cE "^(writing-(fragments|beats|shape)|grill-(me|with-docs))\.md$"`
  > Expected: `5`
- [x] T4: OpenCode 部署透通
  > Command: `ls ~/.config/opencode/commands/ | grep -cE "^(writing-(fragments|beats|shape)|grill-(me|with-docs))\.md$"`
  > Expected: `5`
- [x] T5: command 檔無 skill 殘留標記
  > Command: `grep -l "disable-model-invocation" claude/commands/writing-*.md claude/commands/grill-*.md`
  > Expected: 無輸出（exit code 1）
- [x] T6: 每個 command 檔含 `$ARGUMENTS` 行
  > Command: `grep -l "\$ARGUMENTS" claude/commands/writing-fragments.md claude/commands/writing-beats.md claude/commands/writing-shape.md claude/commands/grill-me.md claude/commands/grill-with-docs.md | wc -l`
  > Expected: `5`
- [x] T7: writing 系列 body 與 upstream 一致（允許偏離僅 frontmatter 與 `$ARGUMENTS` 行）
  > Command: `for s in writing-fragments writing-beats writing-shape; do diff <(curl -s "https://raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/$s/SKILL.md" | sed '1,/^---$/d' | tail -n +2) <(sed '1,/^---$/d' claude/commands/$s.md | tail -n +2 | grep -v '^\(Fragments save path\|Raw material file\): \$ARGUMENTS$') && echo "$s OK"; done`
  > Expected: 每個 skill 輸出 `<skill> OK`（三行），diff 無差異輸出
- [x] T8: repo 無殘留引用（排除 openspec/、.omo/（歷史 plan 文件）與 node_modules/）
  > Command: `grep -rn "skills/writing-fragments\|skills/writing-beats\|skills/writing-shape\|skills/grill-me\|skills/grill-with-docs" --include="*.md" --include="*.json" . | grep -v "^\./openspec/" | grep -v "^\./\.omo/" | grep -v node_modules | wc -l`
  > Expected: `0`
