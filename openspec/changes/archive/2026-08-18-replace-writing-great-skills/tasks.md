# Tasks: replace-writing-great-skills

## 1. Skill 目錄重命名與 vendor 新版內容

- [x] 1.1 `git mv claude/skills/writing-great-skills claude/skills/writing-for-agents`（保留 rename 歷史）
- [x] 1.2 從 upstream 覆寫 `claude/skills/writing-for-agents/SKILL.md`：`curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md`
- [x] 1.3 新增 `claude/skills/writing-for-agents/SKILL-MECHANICS.md`：`curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL-MECHANICS.md`
- [x] 1.4 從 upstream 覆寫 `claude/skills/writing-for-agents/agents/openai.yaml`（新版無 `policy.allow_implicit_invocation: false`）：`curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/agents/openai.yaml`
- [x] 1.5 `git rm claude/skills/writing-for-agents/GLOSSARY.md`（新版定義已 inline，glossary 不存在）

## 2. CLAUDE.md 移除重複 pointer

- [x] 2.1 刪除 `claude/CLAUDE.md` 第 24-25 行（`## Skills 維護規範` 標題與其下的必載規則行），不留空白段落殘留

## 3. 驗證

- [x] 3.1 執行下方全部 T* 驗證項目並確認通過

## Tests

- [x] T1: skill 目錄已重命名且舊目錄不存在
  > Command: `ls claude/skills/ | grep writing`
  > Expected: 僅輸出 `writing-for-agents`，無 `writing-great-skills`
- [x] T2: SKILL.md 與 upstream 逐字元一致
  > Command: `diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md) claude/skills/writing-for-agents/SKILL.md`
  > Expected: 無輸出（exit code 0）
- [x] T3: SKILL-MECHANICS.md 與 upstream 逐字元一致
  > Command: `diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL-MECHANICS.md) claude/skills/writing-for-agents/SKILL-MECHANICS.md`
  > Expected: 無輸出（exit code 0）
- [x] T4: agents/openai.yaml 與 upstream 逐字元一致
  > Command: `diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/agents/openai.yaml) claude/skills/writing-for-agents/agents/openai.yaml`
  > Expected: 無輸出（exit code 0）
- [x] T5: frontmatter 為 model-invoked（無 disable 標記）
  > Command: `grep -c "disable-model-invocation: true" claude/skills/writing-for-agents/SKILL.md; grep -c "allow_implicit_invocation: false" claude/skills/writing-for-agents/agents/openai.yaml`
  > Expected: 兩個指令皆輸出 `0`
- [x] T6: GLOSSARY.md 已刪除且目錄內容完整
  > Command: `ls claude/skills/writing-for-agents/ claude/skills/writing-for-agents/agents/`
  > Expected: 上層含 `SKILL.md`、`SKILL-MECHANICS.md`、`agents`，無 `GLOSSARY.md`；agents/ 僅含 `openai.yaml`
- [x] T7: CLAUDE.md 不再含必載規則
  > Command: `grep -c -e "writing-great-skills" -e "必須先載入" claude/CLAUDE.md`
  > Expected: `0`
- [x] T8: symlink 透通顯示新目錄名
  > Command: `ls ~/.claude/skills/ | grep writing`
  > Expected: 僅輸出 `writing-for-agents`
- [x] T9: live 設定面（claude/）無殘留舊名引用
  > Command: `grep -rn "writing-great-skills" claude/ --include="*.md" --include="*.yaml"`
  > Expected: 無輸出（exit code 1）
  > Note: `openspec/specs/` 的舊名引用由 `openspec archive` 套用 delta 時消除（delta headers 已驗證一致），不屬 apply 階段驗證範圍。
