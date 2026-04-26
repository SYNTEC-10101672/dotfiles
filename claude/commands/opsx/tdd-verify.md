---
name: "OPSX: TDD Verify"
description: Execute TDD verification for OpenSpec tasks using T* items (Red/Green/Final phase). Use after implementing a task to confirm it works before marking [x].
category: Workflow
tags: [workflow, tdd, verify]
---

執行 tasks.md `## 測試` 區塊中 T* 項目的驗證，依結果決定是否 mark `[x]`。

**Input**: 執行階段（Red / Green / Final）與對應的 T* 編號，或從對話 context 推斷。

Use the `openspec-tdd-verify` skill to execute verification.
