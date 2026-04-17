---
description: Creates handover document for next AI session by consolidating remaining tasks, checking for and removing any existing HANDOVER.md first
---

# Handover Command

你現在要為下一個 AI session 創建工作交接文件。請依照以下步驟執行：

## Step 1: 檢查並清理現有 HANDOVER.md

1. 檢查當前工作目錄是否有 `HANDOVER.md`：
   ```bash
   ls -la HANDOVER.md 2>/dev/null && echo "Found" || echo "Not found"
   ```

2. **如果檔案存在**：
   - 讀取檔案內容（使用 Read tool）
   - 向用戶展示現有內容的摘要
   - 使用 AskUserQuestion 詢問：「發現現有的 HANDOVER.md，是否要刪除並創建新的？」
   - 如果用戶同意，執行 `rm HANDOVER.md`

## Step 2: 收集當前上下文

並行執行以下命令收集資訊：

1. **Git 狀態**：
   ```bash
   git status
   ```

2. **最近的 commits**：
   ```bash
   git log --oneline -10
   ```

3. **當前分支資訊**：
   ```bash
   git branch --show-current
   ```

4. **任務列表**（如果有使用 TaskList）：
   - 使用 TaskList tool 獲取所有任務
   - 區分已完成和未完成的任務

## Step 3: 分析並整理資訊

根據收集到的資訊，整理以下內容：

1. **Session Summary**（本次 session 完成了什麼）：
   - 從 git log 分析最近的 commits
   - 從對話歷史總結主要工作
   - 列出已達成的目標

2. **Completed Tasks**（已完成的任務）：
   - 從 TaskList 獲取已完成的任務
   - 從 commits 推斷完成的工作
   - 使用 checkbox 格式：`- [x] Task description`

3. **Remaining Work**（剩餘工作）：
   - 從 TaskList 獲取待完成的任務
   - 從對話歷史找出提到但未完成的工作
   - 按優先級排序（P0/P1/P2）
   - 使用 checkbox 格式：`- [ ] Task description`

4. **Important Context**（重要上下文）：
   - **Recent Decisions**：關鍵技術決策、架構選擇
   - **Blockers**：遇到的問題或阻礙
   - **Modified Files**：列出主要修改的檔案路徑
   - **Dependencies**：新增或更新的依賴
   - **Notes**：任何需要注意的事項

5. **Next Steps**（下一步行動）：
   - 明確列出下一個 AI 應該做什麼
   - 按順序列出優先執行的任務
   - 提供必要的 context（為什麼要做、怎麼做）

## Step 4: 創建 HANDOVER.md

使用 Write tool 創建 `HANDOVER.md`，結構如下：

```markdown
# Handover Document

**Created**: YYYY-MM-DD HH:MM
**Current Branch**: <branch-name>
**Last Commit**: <commit-hash> - <commit-message>

## Session Summary

<總結本次 session 的主要工作和成果>

## Completed Tasks

- [x] Task 1 description
- [x] Task 2 description
- [x] Task 3 description

## Remaining Work

### P0 (Critical)
- [ ] High priority task 1
- [ ] High priority task 2

### P1 (Important)
- [ ] Medium priority task 1
- [ ] Medium priority task 2

### P2 (Nice to have)
- [ ] Low priority task 1

## Important Context

### Recent Decisions
- Decision 1: Rationale
- Decision 2: Rationale

### Blockers
- Blocker 1: Description and potential solution
- Blocker 2: Description and potential solution

### Modified Files
- `path/to/file1.ext` - Brief description of changes
- `path/to/file2.ext` - Brief description of changes

### Dependencies
- Added: package-name@version
- Updated: package-name (old-ver -> new-ver)

### Notes
- Important note 1
- Important note 2

## Next Steps

1. **First Action**: Detailed description of what to do and why
   - Context: Why this is important
   - Approach: How to approach this task

2. **Second Action**: Description
   - Context: ...
   - Approach: ...

3. **Third Action**: Description
   - Context: ...
   - Approach: ...

## Reference Commands

```bash
# Useful commands for the next session
git status
git log --oneline -10
npm test
```

## Links and Resources

- [Relevant Documentation](url)
- [Related Issue/PR](url)
```

## Step 5: 確認完成

1. 執行 `ls -lh HANDOVER.md` 確認檔案創建成功
2. 向用戶報告：
   - HANDOVER.md 已創建
   - 檔案大小
   - 包含的主要內容（摘要）
3. 建議用戶：
   - 在啟動新 session 時先讀取 HANDOVER.md
   - 如果需要可以手動編輯補充資訊

## 重要原則

- **完整性**：確保所有重要資訊都被記錄
- **可執行性**：Next Steps 要足夠具體，讓下一個 AI 可以直接開始工作
- **優先級**：清楚標記任務優先級，避免浪費時間在次要工作
- **語言規範**：
  - HANDOVER.md 內容使用繁體中文
  - 技術術語、檔案路徑、command 保持英文
- **上下文保存**：記錄「為什麼」而非只有「什麼」，幫助下一個 AI 理解決策背景

## 使用時機

- 當前 session 的 context 快滿了
- 需要切換到新的 AI session
- 階段性工作完成，準備交接給其他人或未來的自己
- 遇到需要暫停的長期任務
