## Why

現有 `/handover` command 產生的 HANDOVER.md 是單一厚重文件，跨 session 時會被覆蓋導致歷史遺失，且與 OpenSpec artifacts 完全脫節。需要將 handover 重新設計為 OpenSpec-aware 的雙模式工具：有 active change 時作為薄入口指向 artifacts，沒有 change 時作為完整 context carrier。

## What Changes

- 重寫 `/handover` command 為雙模式設計：薄入口模式（有 active change）與完整模式（無 change）
- 薄入口模式下，handover 過程中同步更新 OpenSpec artifacts（tasks.md 打勾、design.md 追加決策、proposal.md 視需要更新）
- HANDOVER.md 改為輕量文件，使用漸進式披露指向 OpenSpec artifacts
- 在 project CLAUDE.md 加入自動偵測 HANDOVER.md 的規則
- 移除 HANDOVER.md 中冗餘的 Modified Files、Reference Commands、Dependencies 區段

## Capabilities

### New Capabilities
- `handover-openspec-sync`: handover 過程中同步更新 OpenSpec artifacts（tasks.md、design.md、proposal.md），保持持久層與 session 層的一致性
- `handover-dual-mode`: 根據是否有 active change 自動切換 HANDOVER.md 的生成模式（薄入口 vs 完整）

### Modified Capabilities

## Impact

- `claude/commands/handover.md`：完全重寫
- `.claude/CLAUDE.md`：新增 HANDOVER.md 自動偵測規則
