---
description: Interactive commit workflow - reviews changes, checks coding style, discusses what to commit, and executes git commit with proper message
---

# Commit Workflow

你現在進入互動式 commit 流程。請依照以下四個階段執行：

## Phase 1: 檢視修改

執行以下命令檢視當前所有修改：

1. `git status` - 查看所有修改檔案（未追蹤、已修改、已暫存）
2. `git diff` - 查看未暫存的修改
3. `git diff --staged` - 查看已暫存的修改

**並行執行這三個命令**，然後清楚地向用戶展示所有變更。

## Phase 2: Coding Style 檢查

針對修改的檔案，檢查 coding style 是否一致：

1. **讀取修改的檔案**（如果檔案較多，優先檢查主要修改）
2. **檢查項目**：
   - 縮排方式（tabs vs spaces，縮排層級）
   - 命名規範（變數、函數名稱的 case 風格）
   - 格式風格（括號位置、空格使用、行長度）
   - 註解風格（是否使用英文註解，符合 CLAUDE.md 規範）
3. **對比參考**：
   - 同目錄下的其他檔案
   - 專案中同類型檔案
   - CLAUDE.md 的專案規範
4. **如果發現不一致**：
   - 指出具體問題（哪個檔案、哪一行、什麼問題）
   - 建議修正方式
   - 詢問用戶是否要先修正再 commit

## Phase 3: 討論 Commit 內容

與用戶討論此次 commit 應包含哪些檔案：

1. **列出所有修改的檔案**（分類顯示）：
   - 未追蹤的檔案（new files）
   - 已修改的檔案（modified）
   - 已暫存的檔案（staged）
2. **建議合理的分組**：
   - 相關功能應該放在同一個 commit
   - 如果修改跨多個功能領域，建議分開 commit
   - 標記可能應該排除的檔案（臨時檔案、編譯產物、.env 等）
3. **如果有 style 問題**：
   - 建議先修正 style 問題再 commit
   - 或者將 style 修正作為獨立的 commit
4. **詢問用戶確認**：使用 AskUserQuestion tool 詢問要包含哪些檔案

## Phase 4: 執行 Commit

根據用戶確認的檔案清單執行 commit：

1. **Stage 檔案**：
   - 使用 `git add <file1> <file2> ...` 加入指定的檔案
   - 避免使用 `git add .` 或 `git add -A`（除非用戶明確要求）
   - 如果檔案很多，可以一次 add 多個

2. **草擬 Commit Message**：
   - **格式**：`<type>(<scope>): <subject>`
   - **Type**：
     - `feat`: 新功能
     - `fix`: 修復 bug
     - `refactor`: 重構（不改變功能）
     - `docs`: 文檔修改
     - `style`: 格式調整（空格、縮排等）
     - `test`: 測試相關
     - `chore`: 其他雜項（依賴更新、設定檔等）
   - **Scope**（可選）：影響的範圍（模組、元件名稱）
   - **Subject**：
     - 使用英文
     - 簡潔描述修改的「為什麼」而非「什麼」
     - 不超過 50 字元
     - 不使用句號結尾
     - 使用祈使語氣（add, fix, update）
   - **參考最近的 commits**：執行 `git log --oneline -10` 觀察專案的 commit message 風格
   - **不包含署名**：遵循 CLAUDE.md，不添加「by Claude」等署名（Co-Authored-By 會自動加在 body）

3. **詢問用戶確認**：
   - 展示草擬的 commit message
   - 詢問是否需要調整
   - 如果用戶有建議，修改後再次確認

4. **執行 Commit**：
   - 使用 HEREDOC 格式執行 commit：
     ```bash
     git commit -m "$(cat <<'EOF'
     <commit message>

     Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
     EOF
     )"
     ```
   - 執行 `git log -1` 確認 commit 成功
   - 執行 `git status` 顯示當前狀態

## 重要原則

- **遵循 CLAUDE.md 規則**：commit 前需經用戶確認
- **每個階段都與用戶互動**：不要自動執行完所有階段
- **語言規範**：
  - 與用戶溝通使用繁體中文
  - Commit message 使用英文
  - 技術術語保持英文
- **不自動 push**：只完成本地 commit
- **Style 優先**：如果發現 style 問題，建議修正而非直接 commit

## 執行順序

1. 先執行 Phase 1，展示所有修改
2. 執行 Phase 2，檢查 coding style
3. 執行 Phase 3，與用戶討論要 commit 什麼
4. 最後執行 Phase 4，完成 commit

**不要一次執行完所有階段**，每個階段都需要用戶的反饋和確認。
