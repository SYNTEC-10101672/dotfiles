# Tasks: add-matt-workflow

驗證命令皆從 repo 根目錄（`/home/syntec/personal/dotfiles`）執行。

## 1. Vendor skills 落地（opencode/skills/）

從 upstream raw URL 抓取（`https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/<path>`），byte-identical，不含 `agents/`：

- [x] 1.1 建立 `opencode/skills/tdd/`：SKILL.md、tests.md、mocking.md（3 檔） → T1 T2 T3
- [x] 1.2 建立 `opencode/skills/codebase-design/`：SKILL.md、DEEPENING.md、DESIGN-IT-TWICE.md（3 檔） → T1 T2 T3
- [x] 1.3 建立 `opencode/skills/prototype/`：SKILL.md、LOGIC.md、UI.md（3 檔） → T1 T2 T3
- [x] 1.4 建立 `opencode/skills/setup-matt-pocock-skills/`：SKILL.md、domain.md、issue-tracker-github.md、issue-tracker-gitlab.md、issue-tracker-local.md、triage-labels.md（6 檔） → T1 T2 T3

## 2. Slash commands（opencode/commands/）

- [x] 2.1 建立 `to-spec.md`、`to-tickets.md`、`implement.md`：frontmatter 僅 `description`（upstream 原句），body 照搬 upstream `skills/engineering/<name>/SKILL.md`（略過 upstream frontmatter） → T4
- [x] 2.2 建立 `setup-matt-pocock-skills.md` 薄 wrapper：frontmatter 同規則，body 指引載入並執行 `setup-matt-pocock-skills` skill → T4

## 3. 文件與部署

- [x] 3.1 更新 `README.md` 的 `opencode/` 結構描述：commands 列舉加入 matt workflow 系列（to-spec、to-tickets、implement、setup），skills 列舉加入 tdd、codebase-design、prototype、setup-matt-pocock-skills → T6
- [x] 3.2 執行 `make opencode` 並確認部署透通（目錄級 symlink，冪等） → T5

## Tests

- [x] T1: 4 個新 skill 目錄共 15 個檔案存在
  > Command: find opencode/skills/tdd opencode/skills/codebase-design opencode/skills/prototype opencode/skills/setup-matt-pocock-skills -type f | wc -l
  > Expected: 15
- [x] T2: 新資料夾不含 agents/openai.yaml
  > Command: find opencode/skills/tdd opencode/skills/codebase-design opencode/skills/prototype opencode/skills/setup-matt-pocock-skills -name openai.yaml | wc -l
  > Expected: 0
- [x] T3: 15 個 skill 檔與 upstream byte-identical
  > Command: for f in tdd/SKILL.md tdd/tests.md tdd/mocking.md codebase-design/SKILL.md codebase-design/DEEPENING.md codebase-design/DESIGN-IT-TWICE.md prototype/SKILL.md prototype/LOGIC.md prototype/UI.md setup-matt-pocock-skills/SKILL.md setup-matt-pocock-skills/domain.md setup-matt-pocock-skills/issue-tracker-github.md setup-matt-pocock-skills/issue-tracker-gitlab.md setup-matt-pocock-skills/issue-tracker-local.md setup-matt-pocock-skills/triage-labels.md; do diff -q <(curl -sf "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/$f") "opencode/skills/$f" >/dev/null 2>&1 || echo "DIFF: $f"; done; echo DONE
  > Expected: DONE（僅此一行，無任何 DIFF: 行）
- [x] T4: 4 個 command 檔 frontmatter 合規且 body 特徵句在場
  > Command: bash -c 'for c in to-spec to-tickets implement setup-matt-pocock-skills; do grep -q "^description:" "opencode/commands/$c.md" || echo "NO-DESCRIPTION: $c"; grep -q "disable-model-invocation" "opencode/commands/$c.md" && echo "HAS-DMI: $c"; done; grep -q "no interview, just synthesis" opencode/commands/to-spec.md || echo "BODY-MISS: to-spec"; grep -q "tracer bullet" opencode/commands/to-tickets.md || echo "BODY-MISS: to-tickets"; grep -q "Use /tdd where possible" opencode/commands/implement.md || echo "BODY-MISS: implement"; grep -q "setup-matt-pocock-skills" opencode/commands/setup-matt-pocock-skills.md || echo "BODY-MISS: wrapper"; echo CHECKED'
  > Expected: CHECKED（僅此一行）
- [x] T5: make opencode 後新項目部署透通
  > Command: make opencode >/dev/null && ls ~/.config/opencode/commands/ | grep -cE "^(to-spec|to-tickets|implement|setup-matt-pocock-skills)\.md$" && ls ~/.config/opencode/skills/ | grep -cE "^(tdd|codebase-design|prototype|setup-matt-pocock-skills)$"
  > Expected: 4 與 4（兩行，各為 4）
- [x] T6: README.md 已提及新指令
  > Command: grep -q "to-spec" README.md && echo FOUND
  > Expected: FOUND
