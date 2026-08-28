# Proposal: cleanup-claude-md-references

## Why

Skills 與 commands 內有 10 處引用 `CLAUDE.md`（全域指示檔）。這些引用違反 ambient 規則原則（見 `CONTEXT.md`）：system prompt 永遠已載入該檔 — 引用要嘛是零功 pointer（規則已在 context 裡），要嘛是 dangling pointer（sub-agent 讀不到）。其中 `openspec-code-review` 把 system prompt 當審查標準來源，混淆了 generation-time 約束與 review-time 標準。即將進行的 OpenCode 原生化搬遷（AGENTS.md 改名 + 路徑遷移）會讓這些引用 stale，本 change 先清理，讓搬遷成為純機械動作。

## What Changes

- **刪除** `openspec-code-review/SKILL.md` 對 `~/.claude/CLAUDE.md`「程式碼規範」的標準來源引用（4 處：frontmatter description、standards sources 清單、sub-agent brief ×2）— Standards 軸改以 repo documented standards（CODING_STANDARDS.md / CONTRIBUTING.md，if present）+ Fowler 12 smells baseline 為來源，對齊上游（mattpocock/skills 的 code-review）設計
- **刪除** `tutoring/SKILL.md` 整個 "Integration with User Settings" section — 內容為 ambient 規則的重抄（duplication），引用本身是 no-op
- **刪除** `commit.md` 兩處：註解檢查項目的出處註記、對比參考清單的「CLAUDE.md 的專案規範」條目
- **改寫** `eli5.md`：疊加語意改為正面陳述（「衝突時以此為準」），移除檔案引用，保留路徑/指令/config 精確要求
- **對齊** `openspec-apply-change/SKILL.md:104` severity 用語："violates CLAUDE.md" → "violates a documented repo standard"，與 code-review skill 的新語言一致
- **不動** `writing-for-agents/SKILL.md` — 其 CLAUDE.md 字眼是文件類型詞彙（teaching material），非對本 repo 設定檔的引用

## Capabilities

### New Capabilities

- `skill-self-containment`: skills 與 commands 的內容自足性規範 — 不以路徑或重抄方式引用全域指示檔（ambient 規則）；skill 功能所需的規則在 skill 內文明示

### Modified Capabilities

- `openspec-code-review`: Standards 軸的標準來源 requirement 變更 — 移除 `~/.claude/CLAUDE.md`「程式碼規範」段作為必要來源，改為 repo documented standards（CODING_STANDARDS.md / CONTRIBUTING.md，if present）+ Fowler 12 smells baseline；同步修正「新增 skill」與「雙軸平行 sub-agents」兩條 requirement 內文中的 CLAUDE.md 字眼

## Impact

- 修改檔案：`claude/skills/openspec-code-review/SKILL.md`、`claude/skills/tutoring/SKILL.md`、`claude/skills/openspec-apply-change/SKILL.md`、`claude/commands/commit.md`、`claude/commands/eli5.md`
- 行為變化：`/opsx` code review 的 Standards 軸不再檢查全域「程式碼規範」（註解英文、最小變更）— 這些由 generation-time 的 system prompt 約束；「最小變更」的 diff 檢查由 Spec 軸的 scope creep 條目涵蓋
- 不影響部署（`make` targets、symlinks 均不動）
- 為後續 OpenCode 原生化搬遷 change 鋪路：搬遷後 skills/commands 內零全域檔案引用，`git mv` 即純移動
- 附帶（artifact 引用完整性）：`CONTEXT.md` 新增「ambient 規則」glossary 詞條 — proposal 引用該詞彙，需先定義（session 中經 domain-modeling challenge 程序確認）
