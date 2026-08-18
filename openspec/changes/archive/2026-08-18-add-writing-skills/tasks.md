# Tasks: add-writing-skills

> 事實（跨 task 共用）：upstream base URL = `https://raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/`；安裝目標 = `/home/syntec/personal/dotfiles/claude/skills/`（見 design.md Context）。

## 1. Vendor 三個 writing skills

- [x] 1.1 建立 `claude/skills/writing-fragments/`（含 `agents/` 子目錄），從 upstream `writing-fragments/` 抓取 `SKILL.md` 與 `agents/openai.yaml` 原封放入
- [x] 1.2 建立 `claude/skills/writing-shape/`（含 `agents/` 子目錄），從 upstream `writing-shape/` 抓取 `SKILL.md` 與 `agents/openai.yaml` 原封放入
- [x] 1.3 建立 `claude/skills/writing-beats/`（含 `agents/` 子目錄），從 upstream `writing-beats/` 抓取 `SKILL.md` 與 `agents/openai.yaml` 原封放入

## 2. 部署驗證

- [x] 2.1 驗證三個 skill 目錄與檔案存在、內容與 upstream 一致、frontmatter 分類正確、symlink 透通、既有 skills 無變動（執行 T1–T5 全數通過）

## Tests

- [x] T1: 三個 skill 目錄各含 SKILL.md 與 agents/openai.yaml
  > Command: `for s in writing-fragments writing-shape writing-beats; do test -f claude/skills/$s/SKILL.md && test -f claude/skills/$s/agents/openai.yaml && echo "$s OK"; done`
  > Expected: 依序列出 `writing-fragments OK`、`writing-shape OK`、`writing-beats OK` 三行
- [x] T2: SKILL.md 內容與 upstream byte-level 一致
  > Command: `for s in writing-fragments writing-shape writing-beats; do diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/$s/SKILL.md) claude/skills/$s/SKILL.md && echo "$s SKILL.md identical"; done`
  > Expected: 依序列出 `writing-fragments SKILL.md identical`、`writing-shape SKILL.md identical`、`writing-beats SKILL.md identical` 三行
- [x] T3: agents/openai.yaml 內容與 upstream byte-level 一致
  > Command: `for s in writing-fragments writing-shape writing-beats; do diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/$s/agents/openai.yaml) claude/skills/$s/agents/openai.yaml && echo "$s openai.yaml identical"; done`
  > Expected: 依序列出 `writing-fragments openai.yaml identical`、`writing-shape openai.yaml identical`、`writing-beats openai.yaml identical` 三行
- [x] T4: 三者 frontmatter 皆為 user-invoked 且具備 name/description
  > Command: `for s in writing-fragments writing-shape writing-beats; do grep -c 'disable-model-invocation: true' claude/skills/$s/SKILL.md | grep -q 1 && grep -q '^name:' claude/skills/$s/SKILL.md && grep -q '^description:' claude/skills/$s/SKILL.md && echo "$s frontmatter OK"; done`
  > Expected: 依序列出 `writing-fragments frontmatter OK`、`writing-shape frontmatter OK`、`writing-beats frontmatter OK` 三行
- [x] T5: symlink 透通且既有 skills 無變動
  > Command: `ls ~/.claude/skills/ | grep -cE '^(writing-fragments|writing-shape|writing-beats)$' && ls ~/.claude/skills/ | wc -l`
  > Expected: 第一個輸出 `3`（三個新 skill 透過 symlink 透通顯示；精確比對全名，不含既有的 `writing-for-agents`）；第二個輸出 `16`（安裝前基準 13 + 新增 3，既有 skills 無變動）
