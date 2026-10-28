---
description: Land a work branch onto its base branch as a single squashed commit, then delete the work branch - detects the base branch via argument or reflog, refuses on mainline, missing base, or no new commits
argument-hint: "[base branch]"
---

# Land Workflow（落地）

你現在進入落地流程：把 work branch 上的全部變更壓成**單一 commit** 落回 base branch，然後刪掉 work branch。語意等同 `git merge --squash`：不產生 merge commit、沒有第二個 parent。

使用情境：跑完 `/implement` 或 `/implement-spec` 後，work branch 上累積多個 commits，以此指令落地。Base branch 由 `$ARGUMENTS` 參數或 reflog 偵測決定（Phase 2）。請依照以下六個階段執行：

## Phase 1: 前置檢查

三個拒絕條件，任一成立即停止並向用戶說明原因，不繼續後續階段：

1. **主幹線拒絕**：`git branch --show-current` 顯示 current branch 是 `main` 或 `master` 時，current branch 不是 work branch，拒絕執行。
2. **無 base 拒絕**：無法決定 base branch（Phase 2 的參數與 reflog 偵測都失敗，用戶也未提供）時，沒有落點，拒絕執行。
3. **無新 commits 拒絕**：work branch 相對 base branch 沒有任何新 commit（`git log <base>..<work>` 為空）時，沒有可落地的變更，拒絕執行。

條件 2 與 3 需先知道 base branch，在 Phase 2 決定 base 後回頭檢查。

## Phase 2: 決定 base branch

1. **參數覆寫**：`$ARGUMENTS` 有值時，以參數為 base branch，跳過偵測。
2. **reflog 偵測**：否則從 `git reflog` 找**最舊**一筆 `checkout: moving from X to <work branch>`，X 即 base branch（reflog 由新到舊排列，`tail -1` 取最舊）：
   ```bash
   git reflog --grep-reflog="checkout: moving from" | grep "to <work branch>$" | tail -1
   ```
3. **找不到問用戶**：reflog 偵測不到時，問用戶 base branch 是哪條；用戶未提供則依條件 2 拒絕。
4. **檢查新 commits**：執行 `git log <base>..<work> --oneline`，清單為空則依條件 3 拒絕。

## Phase 3: dirty tree

執行 `git status --porcelain`，有輸出時，未 commit 變更先 commit 進 work branch：

- 未 commit 變更必須落在 work branch 上，才會被壓進單一 commit
- 這個 commit 的 message 簡短即可（落地時會被壓縮，不會保留）

## Phase 4: 報告與確認（單一確認點）

向用戶完整顯示落地計畫，這是整個流程**唯一**的確認點：

1. **base branch**：名稱與來源（參數或 reflog 偵測）
2. **work branch**：current branch 名稱
3. **commits 清單**：`git log <base>..<work> --oneline` 的完整輸出
4. **草擬 commit message**：
   - **格式**：`<type>(<scope>): <subject>`
   - **Type**：`feat`/`fix`/`refactor`/`docs`/`style`/`test`/`chore`（新功能、修復 bug、重構、文檔、格式、測試、雜項）
   - **Subject**：使用英文、不超過 50 字元、祈使語氣、不以句號結尾
   - 參考 commits 清單歸納整體變更，描述「為什麼」而非逐條列表
   - 不添加 AI 署名 trailer

經用戶確認後才進入 Phase 5。

## Phase 5: 執行

依序執行：

1. `git checkout <base>`
2. `git merge --squash <work>`
3. 用 Phase 4 確認的 message 執行 `git commit`（HEREDOC 格式）

**衝突處理**：`git merge --squash` 失敗（exit code 非 0）時，立即停止後續步驟，報告衝突檔案，問用戶如何處理。不自動解衝突，也不自動 abort。

## Phase 6: 收尾

1. `git branch -D <work>` 刪掉 work branch
2. 執行 `git log -1` 與 `git status`，向用戶確認落地結果

## 重要原則

- **不 push**：只完成本地 commit，不執行 `git push`
- **不動 tickets**：不修改、不解析 issue tracker 的 tickets（`.scratch/` 下的狀態由 orchestrator 處理）
- **單一確認點**：整個流程只在 Phase 4 確認一次，確認後 Phase 5、6 連續完成；唯一例外是衝突時停下問用戶
- **衝突不自動解**：停下、報告、問用戶
- **squash 語意**：目的是最終狀態 — base branch 上恰多一個 commit；不產生 merge commit、沒有第二個 parent
- **語言規範**：
  - 與用戶溝通使用繁體中文
  - Commit message 使用英文
  - 技術術語保持英文

## 執行順序

1. Phase 1 檢查 current branch，Phase 2 決定 base 並回頭完成全部拒絕條件檢查
2. Phase 3 處理 dirty tree
3. Phase 4 停下，等用戶確認
4. 確認後執行 Phase 5、Phase 6 完成落地
