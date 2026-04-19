---
name: "OPSX: TDD Verify"
description: Execute the verification block of the current OpenSpec task and mark it complete
category: Workflow
tags: [workflow, tdd, verify]
---

執行當前 task 的 `> 驗證：` 區塊，依結果決定是否 mark `[x]`。

**Input**: 當前正在實作的 task（從對話 context 推斷，或明確指定）。

Use the `openspec-tdd-verify` skill to execute verification.
