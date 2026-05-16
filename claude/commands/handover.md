---
description: Creates handover document for next AI session — auto-detects active OpenSpec change and switches between thin-entry and full mode
---

# Handover Command

你現在要為下一個 AI session 創建工作交接文件。

## Step 1: 清理現有 HANDOVER.md

```bash
rm -f HANDOVER.md
```

HANDOVER.md 是 session 層文件，每次交接直接覆寫。

## Step 2: 偵測 Active Change

```bash
for f in openspec/changes/*/proposal.md; do [ -f "$f" ] && basename "$(dirname "$f")"; done
```

根據輸出決定模式：

- **無輸出**（無 active change）→ 完整模式，跳至 Step 5
- **一個 change** → 記錄名稱，薄入口模式，繼續 Step 3
- **多個 change** → 使用 AskUserQuestion 讓使用者選擇要交接哪個 change，然後繼續 Step 3

## Step 3: 同步 OpenSpec Artifacts（薄入口模式）

在產生 HANDOVER.md 前，先同步更新持久層 artifacts。

### 3a. 更新 tasks.md 勾選狀態

1. 回顧本次 session 完成的工作
2. 讀取 `<change-dir>/tasks.md`
3. 對於本次 session 已完成的 task（`## 實作` 區塊中的 `- [ ]`），使用 Edit tool 精確替換為 `- [x]`
4. 未完成的項目不動

### 3b. 追加 design.md 決策

1. 回顧本次 session 是否有新的技術決策
2. 讀取 `<change-dir>/design.md`，確認 Decisions 區段
3. 如果有新決策，使用 Edit tool 在 `## Decisions` 區段末尾追加 `### N. 決策標題` + 說明
4. 沒有新決策則跳過

### 3c. 更新 proposal.md（僅在 scope 變動時）

1. 判斷本次 session 是否變更了 scope（新增/移除/修改 capabilities）
2. 如果有，使用 Edit tool 更新 proposal.md 對應區段
3. 沒有變動則跳過

## Step 4: 產生薄入口 HANDOVER.md

使用 Write tool 創建 `HANDOVER.md`，模板如下。填入實際內容，確保總長度 ≤ 50 行。

```
# Handover

**Session**: <YYYY-MM-DD>
**Active Change**: <change-name>
**Mode**: Thin Entry（OpenSpec-aware）

## Session 簡述

<1-2 句話描述本次 session 做了什麼>

## 進度

- Tasks: <N>/<M> complete
- Current: <正在處理的 task 或「全部完成」>

## 本次 Session 決策

- <決策 1>（無則省略此區段）

## 下一步

1. <下一個 task 及其要點>

## Context 指引

讀取以下 artifacts 恢復完整 context：
- `openspec/changes/<change-name>/proposal.md`
- `openspec/changes/<change-name>/design.md`
- `openspec/changes/<change-name>/tasks.md`
- `openspec/changes/<change-name>/specs/`
```

跳至 Step 6。

## Step 5: 產生完整模式 HANDOVER.md（無 active change）

收集 context：

```bash
git log --oneline -10
git branch --show-current
```

使用 TaskList tool 獲取任務狀態（如果有）。

使用 Write tool 創建 `HANDOVER.md`，模板如下。只記錄「為什麼」而非只有「什麼」。

```
# Handover

**Session**: <YYYY-MM-DD>
**Branch**: <branch-name>
**Mode**: Full（無 active OpenSpec change）

## Session 摘要

<總結本次 session 的主要工作和成果>

## 已完成工作

- [x] Task 1
- [x] Task 2

## 剩餘工作

### P0
- [ ] ...

### P1
- [ ] ...

## 決策

- Decision: Rationale

## 開放問題

- Issue（無則省略此區段）

## 下一步

1. **Action**: Description
   - Context: Why
   - Approach: How

<若探索已有明確方向，建議使用 /opsx:propose 正式化結論>
```

注意：不包含 Modified Files、Reference Commands、Dependencies、Links and Resources。

## Step 6: 確認完成

```bash
ls -lh HANDOVER.md
```

向用戶報告 HANDOVER.md 已創建及其模式。

## 語言規範

- HANDOVER.md 內容使用繁體中文
- 技術術語、檔案路徑、command 保持英文
