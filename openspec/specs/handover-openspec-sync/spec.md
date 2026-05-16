# Capability: handover-openspec-sync

## Purpose
Handover 過程中自動同步更新 OpenSpec artifacts（tasks.md、design.md、proposal.md），確保交接時 artifacts 反映最新的 session 狀態。

## Requirements

### Requirement: Handover syncs task completion to tasks.md
當有 active OpenSpec change 時，handover 過程中 SHALL 將本次 session 完成的 tasks 在 tasks.md 中從 `[ ]` 更新為 `[x]`。

#### Scenario: Tasks completed during session
- **WHEN** 執行 `/handover` 且有 active change，且 tasks.md 中有 `[ ]` 項目在本次 session 已完成
- **THEN** handover SHALL 使用 Edit tool 將對應項目更新為 `[x]`

#### Scenario: No tasks completed
- **WHEN** 執行 `/handover` 且有 active change，但本次 session 沒有完成任何 task
- **THEN** tasks.md 保持不變

### Requirement: Handover appends decisions to design.md
當有 active OpenSpec change 時，handover 過程中 SHALL 將本次 session 產生的新決策追加到 design.md 的 Decisions 區段。

#### Scenario: New decisions made during session
- **WHEN** 執行 `/handover` 且有 active change，且本次 session 有新的技術決策
- **THEN** handover SHALL 在 design.md 的 Decisions 區段追加新決策，格式遵循現有的 `### N. 決策標題` + 說明模式

#### Scenario: No new decisions
- **WHEN** 執行 `/handover` 且有 active change，但本次 session 沒有新決策
- **THEN** design.md 保持不變

### Requirement: Handover updates proposal.md only on scope change
當有 active OpenSpec change 且 scope 確實變動時，handover SHALL 更新 proposal.md。

#### Scenario: Scope changed during session
- **WHEN** 執行 `/handover` 且有 active change，且本次 session 變更了 scope（新增/移除/修改 capabilities）
- **THEN** handover SHALL 更新 proposal.md 的 What Changes 或 Capabilities 區段

#### Scenario: Scope unchanged
- **WHEN** 執行 `/handover` 且 scope 未變動
- **THEN** proposal.md 保持不變

### Requirement: Artifact updates use targeted edits
handover 對 OpenSpec artifacts 的更新 SHALL 使用精確的 targeted edit（Edit tool），而非覆蓋整個文件。

#### Scenario: Updating tasks.md checkboxes
- **WHEN** handover 更新 tasks.md
- **THEN** SHALL 使用 Edit tool 的 `old_string`/`new_string` 精確替換 `[ ]` 為 `[x]`

#### Scenario: Appending to design.md
- **WHEN** handover 追加決策到 design.md
- **THEN** SHALL 使用 Edit tool 在現有 Decisions 區段末尾追加，不覆蓋已有內容
