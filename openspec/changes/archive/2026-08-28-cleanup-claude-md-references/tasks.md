# Tasks: cleanup-claude-md-references

編輯依據：design.md Decisions 表（D1–D9）。所有編輯為內容修改，檔案位置不動。

## 1. openspec-code-review（D1–D4）

- [x] 1.1 `claude/skills/openspec-code-review/SKILL.md:3` frontmatter description：`Standards (CLAUDE.md code standards + Fowler smells baseline)` → `Standards (documented repo standards + Fowler smells baseline)`，其餘字句不動
- [x] 1.2 同檔 `:33` 刪除整行：`- \`~/.claude/CLAUDE.md\` "程式碼規範" section (code standards)`（standards sources 清單從 repo 條目開始）
- [x] 1.3 同檔 `:58` brief 括號：`(include diff command, commit list, CLAUDE.md code standards section content, full Fowler 12 baseline list)` → `(include diff command, commit list, the standards-source files found in step 3, full Fowler 12 baseline list)`
- [x] 1.4 同檔 `:61`：`(a) violations of CLAUDE.md code standards (cite rule)` → `(a) violations of documented repo standards (cite file + rule)`

## 2. tutoring（D5）

- [x] 2.1 `claude/skills/tutoring/SKILL.md` 刪除整個 "Integration with User Settings" section：從 `:367` 的 `## Integration with User Settings` heading（含其前空行）至 `## Example: Full Tutoring Response` heading 前止；兩個 heading 相鄰後中間保留單一空行

## 3. commit.md（D6–D7）

- [x] 3.1 `claude/commands/commit.md:28`：`註解風格（是否使用英文註解，符合 CLAUDE.md 規範）` → `註解風格（是否使用英文註解）`
- [x] 3.2 `claude/commands/commit.md:32` 刪除整行：`   - CLAUDE.md 的專案規範`（對比參考清單保留同目錄檔案、專案同類型檔案兩條）

## 4. eli5.md（D8）

- [x] 4.1 `claude/commands/eli5.md` 內文兩處改寫：
  - `:7` `在 CLAUDE.md 的基礎上，本 session 接下來「額外」啟用：` → `本 session 啟用 ELI5 模式（疊加於既有規則，衝突時以此為準）：`
  - `:12` `（檔案路徑、指令、config 值仍維持精確 — 沿用 CLAUDE.md 基本溝通。）` → `檔案路徑、指令、config 值維持原樣精確。`
  - 兩個 bullet（只回三件事／能短就短）不動；frontmatter 不動

## 5. openspec-apply-change（D9）

- [x] 5.1 `claude/skills/openspec-apply-change/SKILL.md:104`：`(violates CLAUDE.md / major Fowler smell)` → `(violates a documented repo standard / major Fowler smell)`

## Tests

- [x] T1: skills 與 commands（排除 writing-for-agents）無 CLAUDE.md / AGENTS.md 引用
  > Command: `grep -rnE "CLAUDE\.md|AGENTS\.md" claude/skills claude/commands --include='*.md' | grep -v 'writing-for-agents/'`
  > Expected: 無輸出（exit code 1）
- [x] T2: code-review standards sources 無 `~/.claude` 路徑且保留 repo 條目
  > Command: `grep -c '~/.claude' claude/skills/openspec-code-review/SKILL.md; grep -c 'CODING_STANDARDS.md' claude/skills/openspec-code-review/SKILL.md`
  > Expected: `0`，然後 `1`
- [x] T3: eli5 疊加語意存在
  > Command: `grep -c '衝突時以此為準' claude/commands/eli5.md`
  > Expected: `1`
- [x] T4: severity 用語對齊
  > Command: `grep -c 'documented repo standard' claude/skills/openspec-apply-change/SKILL.md`
  > Expected: `1`
- [x] T5: tutoring section 已刪除
  > Command: `grep -c 'Integration with User Settings' claude/skills/tutoring/SKILL.md`
  > Expected: `0`（grep exit code 1）
- [x] T6: writing-for-agents 未被修改
  > Command: `git diff --stat -- claude/skills/writing-for-agents/`
  > Expected: 無輸出
