---
name: "OPSX: Re-verify"
description: Reset all T* items in tasks.md ## 測試 block and re-run Final phase verification. Use after /simplify (refactor) to confirm all tests still pass.
category: Workflow
tags: [workflow, tdd, verify]
---

在 refactor（`/simplify`）後，重新驗證 tasks.md `## 測試` 區塊的所有 T* 項目。

**Steps**

1. **找到當前 change 的 tasks.md**

   執行 `openspec list --json` 取得 active change，讀取其 tasks.md。

   若有多個 active change，用 **AskUserQuestion tool** 讓使用者選擇。

2. **Reset `## 測試` 區塊的所有 T* 項目**

   把 `## 測試` 區塊中所有 `- [x]` 改回 `- [ ]`。

   **只處理 `## 測試` 區塊**，`## 實作` 區塊的 task 狀態不變。

3. **執行 Final phase 驗證**

   Use the `openspec-tdd-verify` skill to execute **Final phase** verification on all T* items.
