## 測試

T1: 4 個 skill 子目錄與 SKILL.md 檔案存在
> 指令：`ls /home/syntec/personal/dotfiles/claude/skills/{grill-me,grilling,writing-great-skills,domain-modeling}/SKILL.md`
> 預期：4 個檔案路徑都被列出，無 "No such file or directory" 訊息

T2: grill-me SKILL.md 內容與 upstream main 分支完全一致
> 指令：`curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md | diff - /home/syntec/personal/dotfiles/claude/skills/grill-me/SKILL.md`
> 預期：無 diff 輸出（exit code 0）

T3: 附帶的 reference 檔案一併複製
> 指令：`ls /home/syntec/personal/dotfiles/claude/skills/writing-great-skills/GLOSSARY.md /home/syntec/personal/dotfiles/claude/skills/domain-modeling/CONTEXT-FORMAT.md /home/syntec/personal/dotfiles/claude/skills/domain-modeling/ADR-FORMAT.md`
> 預期：3 個檔案都被列出，無錯誤訊息

T4: 透過 symlink 即時可見
> 指令：`ls /home/syntec/.claude/skills/ | grep -E '^(grill-me|grilling|writing-great-skills|domain-modeling)$'`
> 預期：依序列出 4 個名稱（grill-me、domain-modeling、grilling、writing-great-skills）

T5: 每個 SKILL.md 的 frontmatter 包含 name 與 description
> 指令：`for f in grill-me grilling writing-great-skills domain-modeling; do echo "=== $f ==="; awk '/^---$/{c++; next} c==1' /home/syntec/personal/dotfiles/claude/skills/$f/SKILL.md; done`
> 預期：4 個檔案的 YAML frontmatter 區塊都包含 `name:` 與 `description:` 兩個欄位

T6: user-invoked skills 標記 disable-model-invocation: true
> 指令：`grep -l 'disable-model-invocation: true' /home/syntec/personal/dotfiles/claude/skills/grill-me/SKILL.md /home/syntec/personal/dotfiles/claude/skills/writing-great-skills/SKILL.md`
> 預期：兩個檔案路徑都被列出（grep 命中 2 個）

T7: model-invoked skills 不含 disable-model-invocation: true
> 指令：`grep 'disable-model-invocation' /home/syntec/personal/dotfiles/claude/skills/grilling/SKILL.md /home/syntec/personal/dotfiles/claude/skills/domain-modeling/SKILL.md; echo "exit=$?"`
> 預期：grep 無命中（exit code 1）

T8: 既有 skills 完整保留（只有新增、沒有修改或刪除）
> 指令：`cd /home/syntec/personal/dotfiles && git status --short claude/skills/ | grep -vE '^\?\?' || echo "no modifications"`
> 預期：輸出 "no modifications"（所有變動都是 untracked 新檔，沒有 M 或 D 狀態）

T9: 子目錄名稱不與既有 skills 衝突
> 指令：`comm -12 <(ls /home/syntec/personal/dotfiles/claude/skills/ | sort) <(printf '%s\n' grill-me grilling writing-great-skills domain-modeling | sort) | wc -l`
> 預期：輸出 4（這 4 個名稱確實存在於目錄中）。若輸出大於 4 表示有重複計算；若安裝前執行應為 0

## 實作

### 1. 取得 upstream 並複製到 dotfiles

- [x] 1.1 git clone mattpocock/skills main 分支到 /tmp/matt-skills（→ T1, T2, T3）
  - 路徑：`/tmp/matt-skills/`
  - upstream：`https://github.com/mattpocock/skills.git`，分支 `main`
- [x] 1.2 從 /tmp/matt-skills/skills/productivity/ 複製 grill-me、grilling、writing-great-skills 三個子目錄到 `/home/syntec/personal/dotfiles/claude/skills/`（→ T1, T8, T9）
  - 注意：writing-great-skills 子目錄包含 GLOSSARY.md，必須整個子目錄複製（→ T3）
  - 決策：連 `agents/openai.yaml`（Codex 用 metadata）一併整個子目錄複製，保持 true vendor copy
- [x] 1.3 從 /tmp/matt-skills/skills/engineering/ 複製 domain-modeling 子目錄到 `/home/syntec/personal/dotfiles/claude/skills/`（→ T1, T3, T8）
  - 注意：domain-modeling 子目錄包含 CONTEXT-FORMAT.md 與 ADR-FORMAT.md，必須整個子目錄複製
- [x] 1.4 清理 `/tmp/matt-skills/`（純 housekeeping，無對應測試）

### 2. 驗證安裝結果

- [x] 2.1 執行 T1-T9 全部測試指令，確認所有預期都滿足（→ T1, T2, T3, T4, T5, T6, T7, T8, T9）
  - 結果：T1-T7、T9 全部 pass。T8 test command 抓到 pre-existing staged 變動（openspec-apply-change/SKILL.md、openspec-propose/SKILL.md staged M；openspec-code-review/SKILL.md staged A），但 `git diff --stat` 對這些檔案輸出空表示 working tree 與 index 一致，為使用者既有 work-in-progress，與本次安裝無關。本次安裝只新增 4 個 untracked 子目錄，spec intent 滿足
- [x] 2.2 若任一測試失敗，回到實作步驟 1 修正後重跑 2.1
  - 不需修正

### 3. Commit 準備（不執行 commit，僅預備）

- [x] 3.1 `cd /home/syntec/personal/dotfiles && git status claude/skills/` 確認只有 4 個新子目錄（→ T8）
  - 確認 untracked 項目只有 domain-modeling/、grill-me/、grilling/、writing-great-skills/ 4 個
- [x] 3.2 與使用者確認 commit message 後再執行 commit（commit message 由使用者審視階段決定）
  - 已執行：commit 46d1570（feat(claude): add mattpocock skills...），16 files / 754 insertions
