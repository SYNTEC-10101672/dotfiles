## Why

`claude/CLAUDE.md` 是 user-level always-loaded memory（每個 session、每個 turn、每個 repo 都計入 context），目前 56 行中有重複語義、no-op 指令、與 `/commit` skill 重疊且互相矛盾的 Git 規範。依 writing-for-agents 的檢驗標準（每行必須改變行為 vs. model default），需要 dedup 與重新安置 branch-specific 規則。

## What Changes

- 刪除 `claude/CLAUDE.md` 的「Git 規範」整節（3 行）：
  - Conventional Commits 規則 → 已由 `claude/commands/commit.md` 涵蓋（且更完整）
  - 「commit 前需確認」→ `/commit` 流程本身是互動式；ad-hoc commit 走 permission prompt
  - 「不含 by Claude 署名」→ 改由 `claude/settings.json` 的 `attribution` 機械強制
- 修復 `claude/commands/commit.md` 的矛盾與過期內容：
  - 移除手動添加的 `Co-Authored-By: Claude Sonnet 4.5` trailer（與「不含署名」規則矛盾，model name 已過期）
  - 將 :82 :104 指向 CLAUDE.md 的 dangling pointer 就地 inline，改為 skill 內自包含的規則
- `claude/settings.json` 新增 `attribution` 設定（`commit: ""`、`pr: ""`），機械式隱藏 attribution（`includeCoAuthoredBy` 已 DEPRECATED，改用 `attribution`）
- `claude/CLAUDE.md` 其餘段落 dedup：
  - 「精準產出」+「最小變更」合併為一節「精準與最小變更」（兩節一義：scope discipline）
  - 「讀後再改」刪除 read-before-edit 半句（Edit/Write tool 已機械強制 read-before-edit），只留「讀同目錄相關檔案、識別慣例」
  - 「基本溝通」合併 anti-sycophancy 兩句（留正面表述）
  - 「釐清優先」合併重複的「不確定 → 發問」兩個 bullet
  - 「文件規範」H2（僅 1 行）摺進「溝通原則」成 bullet
  - 「領域知識規範」合併 bullet 1 + 4（存在就讀 / 不存在靜默繼續）

## Capabilities

### New Capabilities
- `commit-rules-placement`: Git commit 規則的安置層級 — 流程規則住 `/commit` skill（invoked 才載入）、機械規則（attribution）住 `claude/settings.json`、CLAUDE.md 不再承載 branch-specific Git 規則

### Modified Capabilities
<!-- 無：既有 specs（domain-knowledge-layer、claude-config-symlink、project-claude-md）的需求皆不受影響
     （領域知識規範僅合併 bullets，語義不變；無 spec 引用 Git 規範段落） -->


## Impact

- `claude/CLAUDE.md`：56 行 → 41 行，語義零損失（每條保留的規則都可追溯到原行）
- `claude/commands/commit.md`：移除 Co-Authored-By trailer、inline 兩處 pointer
- `claude/settings.json`：新增 `attribution` 區塊
- 影響範圍：Claude Code 與 opencode（兩者皆載入此 CLAUDE.md 作為 instructions）
- 部署：`make claude` symlink 的目標內容變更，無 symlink 結構改動
