# Tasks: sync-mattpocock-skills

## Implementation

- [x] 1. 覆蓋 `opencode/skills/grilling/`：取得 upstream `skills/productivity/grilling/` 最新版（`git clone --depth 1 https://github.com/mattpocock/skills /tmp/opencode/mattpocock-skills` 或 `curl` 對應 raw 檔），以 `SKILL.md` + `agents/openai.yaml` 完整覆蓋本地目錄（byte-identical，無本地修改）(→ T1)
- [x] 2. 覆蓋 `opencode/skills/domain-modeling/`：upstream `skills/engineering/domain-modeling/` 最新版三檔 `SKILL.md`、`CONTEXT-FORMAT.md`、`ADR-FORMAT.md` + `agents/openai.yaml` 覆蓋本地（ADR 支援回歸：`ADR-FORMAT.md` 重新存在、`SKILL.md` 含 "Offer ADRs sparingly" 段落）(→ T2)
- [x] 3. 覆蓋 `opencode/skills/writing-for-agents/`：upstream `skills/productivity/writing-for-agents/` 最新版三檔 `SKILL.md`、`SKILL-MECHANICS.md` + `agents/openai.yaml` 覆蓋本地 (→ T3)
- [x] 4. 新增 `opencode/skills/code-review/`：upstream `skills/engineering/code-review/`（`SKILL.md` + `agents/`）原封複製，byte-identical (→ T4)
- [x] 5. 修改 `opencode/commands/opsx/apply.md` Step 7：將 line 98 的 `` Invoke `openspec-code-review` skill to review the diff with parallel sub-agents. `` 改寫為 invoke `code-review` skill，並於呼叫處提供三項適配資訊——spec source 為 active change artifacts（`openspec/changes/<name>/` 的 proposal.md、specs/、design.md、tasks.md）、fixed point 為 `git merge-base <change-start-commit> HEAD`、無 issue tracker（跳過 tracker-based spec discovery）(→ T5)
- [x] 6. 刪除 `opencode/skills/openspec-code-review/` 整個目錄 (→ T5, T6)
- [x] 7. 修改 `opencode/AGENTS.md`：於「## 執行原則」段末補入規範行「完成 `/opsx:apply` 後，必須執行 `code-review`（雙軸 sub-agents）通過才能建議 archive；若 code-review 有 fix，fix 後必須重跑 Final phase tests 確認沒退化」(→ T7)
- [x] 8. 驗證部署：執行 `make check` 確認 `~/.config/opencode/skills` symlink 狀態正常，`ls ~/.config/opencode/skills/` 可見 `code-review` 且無 `openspec-code-review` (→ T8)

## Tests

- [x] T1: `grilling` 與 upstream byte-identical
  > Command: `diff <(curl -fsSL https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md) opencode/skills/grilling/SKILL.md && echo GRILLING_IDENTICAL`
  > Expected: 輸出 `GRILLING_IDENTICAL`（diff 無差異）
- [x] T2: `domain-modeling` ADR 支援回歸
  > Command: `test -f opencode/skills/domain-modeling/ADR-FORMAT.md && grep -c "Offer ADRs sparingly" opencode/skills/domain-modeling/SKILL.md`
  > Expected: exit 0 且 grep 輸出 `1`（段落存在一次）
- [x] T3: `writing-for-agents` 與 upstream byte-identical
  > Command: `diff <(curl -fsSL https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md) opencode/skills/writing-for-agents/SKILL.md && echo WFA_IDENTICAL`
  > Expected: 輸出 `WFA_IDENTICAL`
- [x] T4: `code-review` 新增且與 upstream byte-identical
  > Command: `test -f opencode/skills/code-review/agents/openai.yaml && diff <(curl -fsSL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md) opencode/skills/code-review/SKILL.md && echo CR_IDENTICAL`
  > Expected: 輸出 `CR_IDENTICAL`
- [x] T5: 無 dangling 引用——`openspec-code-review` 字樣歸零、apply.md 引用 `code-review` 且含適配資訊
  > Command: `! grep -rn "openspec-code-review" opencode/ && grep -n "code-review" opencode/commands/opsx/apply.md | head -1 && grep -n "merge-base" opencode/commands/opsx/apply.md | head -1`
  > Expected: 三段皆成功（grep -rn 無輸出使 `!` 為真；後兩個 grep 各列出至少一行）
- [x] T6: `openspec-code-review/` 目錄已刪除
  > Command: `test ! -d opencode/skills/openspec-code-review && echo REMOVED`
  > Expected: 輸出 `REMOVED`
- [x] T7: AGENTS.md 含必跑規範
  > Command: `grep -n "code-review" opencode/AGENTS.md | head -1`
  > Expected: 列出一行含 `code-review` 的規範文字
- [x] T8: symlink 部署可見新 skill
  > Command: `ls ~/.config/opencode/skills/ | grep -E "^code-review$|^openspec-code-review$"`
  > Expected: 只輸出 `code-review`（無 `openspec-code-review`）
