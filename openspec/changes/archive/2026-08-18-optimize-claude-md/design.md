## Context

- `claude/CLAUDE.md`（deploy 到 `~/.claude/CLAUDE.md`）是 user-level always-loaded memory，同時被 opencode 讀取。每一行都是 per-turn context cost。
- `claude/commands/commit.md`（`/commit` skill）已內含完整 Conventional Commits 規範與互動式確認流程，其中 :82 :104 兩處 pointer 引用 CLAUDE.md 的 Git 規範，:95 手動添加 `Co-Authored-By: Claude Sonnet 4.5` trailer — 與 CLAUDE.md「不含署名」規則矛盾，且 model name 已過期。
- `claude/settings.json` 目前無 attribution 相關設定。
- Claude Code settings schema：`includeCoAuthoredBy` 已標記 DEPRECATED，現行 key 為 `attribution: { commit, pr, sessionUrl }`，空字串隱藏 attribution。
- 使用者決策（explore session 結論）：
  1. Co-Authored-By trailer：不要
  2. 「精準產出」+「最小變更」合併：同意
  3. read-before-edit 半句刪除：同意

### 環境事實（跨 task 共用）

- CLAUDE.md 路徑：`claude/CLAUDE.md`（repo）→ `~/.claude/CLAUDE.md`（symlink）
- commit skill 路徑：`claude/commands/commit.md` → `~/.claude/commands/commit.md`
- settings 路徑：`claude/settings.json` → `~/.claude/settings.json`

## Goals / Non-Goals

**Goals:**

- CLAUDE.md 每一行都通過「改變行為 vs. model default」檢驗（no-op 刪除、duplication 合併）
- Git 規則安置於正確層級：流程規則在 `/commit` skill（invoked 才載入）、機械規則在 settings.json（強制執行）
- 消除 commit.md 與 CLAUDE.md 的矛盾（署名）與 dangling pointer

**Non-Goals:**

- 不重寫 `/commit` skill 的流程設計（四階段互動維持不變）
- 不動 CLAUDE.md 的「執行原則」「領域知識規範」的語義內容（僅格式合併）
- 不處理 opencode 端的 attribution（opencode 有自己的機制，另行處理）
- 不清理 README.md 中對 CLAUDE.md 的描述（無 drift）

## Decisions

### D1: attribution 用 `attribution` key 而非 DEPRECATED 的 `includeCoAuthoredBy`

- 選擇：`"attribution": { "commit": "", "pr": "" }`
- 替代方案：`"includeCoAuthoredBy": false` —官方 schema 已標 DEPRECATED，新配置不應採用
- 注意：`sessionUrl` 未設 → 維持 default `true`（web session 才生效，本地 CLI 無影響）

### D2: CLAUDE.md 刪 Git 規範，規則不改寫進其他 prose

- Conventional Commits → commit.md 已有更完整版本（type 清單、subject 規則、50 字元限制）
- 「commit 前確認」→ commit.md Phase 3/4 的 AskUserQuestion 流程已保證；ad-hoc commit 由 permission 系統 prompt（`git commit` 不在 settings.json allow list）
- 「不含署名」→ settings.json `attribution` 機械強制，比 prose 可靠

### D3: commit.md 的 pointer 就地 inline，不自建反向 pointer

- :82「遵循 CLAUDE.md，不添加 by Claude 署名」→ 改為「不添加 AI 署名 trailer（Co-Authored-By 等）」，自包含
- :104「遵循 CLAUDE.md 規則：commit 前需經用戶確認」→ 改為「commit 執行前需展示 message 並經用戶確認」（流程本身已如此，僅移除外部引用）
- :95 HEREDOC 範例移除 Co-Authored-By 行

### D4: 合併後的「精準與最小變更」保留雙方 live 條目

- 保留：可追溯性、不做未要求的功能/抽象/彈性、單次使用不抽象化、不可能場景不錯誤處理、50 行 vs 200 行、資深工程師檢驗、dead code 提而不刪、孤立符號只清自己的
- 刪除（一義重複）：「不要順手重構」「不要重構沒壞的」「不要改善相鄰的」→ 由「可追溯到需求」涵蓋

### D5: 語義零損失驗證準則

- 每條保留規則可追溯到原 CLAUDE.md 行號；刪除行必須歸類為 (a) no-op（工具/default 已保證）或 (b) duplication（他行已涵蓋）或 (c) 移至 skill/settings

## Risks / Trade-offs

- [opencode 也吃這份 CLAUDE.md，ad-hoc commit 的「確認」行為在 opencode 端依賴其 permission 機制] → 已確認 opencode 有獨立 permission prompt；若未來 drift，在 opencode 端單獨設定
- [settings.json 的 `attribution` 是新版 key，舊版 Claude Code 不認得] → 需 Claude Code ≥ 支援 attribution 的版本；部署後以 `/status` 確認載入
- [刪除 read-before-edit 半句後，非 tool-mediated 的情境（如 bash sed 直接改檔）失去 prose 提醒] → 接受：CLAUDE.md「執行原則」已要求修改前確認行為；且主要編輯路徑都走 Edit/Write tool
- [合併段落可能改變 model 對個別規則的注意力權重] → 語義等價合併、條目數減少反而提升每條注意力；上線後觀察行為 drift

## Migration Plan

1. 修改三檔（CLAUDE.md、commit.md、settings.json）
2. `make claude` 確認 symlink 指向不變（內容變更自動生效）
3. 驗證：新 session 載入 CLAUDE.md、`/status` 確認 settings 載入
4. Rollback：`git checkout` 三檔即可，無資料遷移

## Open Questions

無 — explore session 已解決全部三個決策點。
