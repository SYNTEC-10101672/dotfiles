# Delta Spec: handover-dual-mode

## ADDED Requirements

### Requirement: AGENTS.md auto-detects HANDOVER.md
repo root `AGENTS.md` SHALL 包含一條規則：session 開始時若偵測到 HANDOVER.md 存在，自動讀取並根據指引恢復 context。

#### Scenario: HANDOVER.md exists at session start
- **WHEN** 新 session 開始且 project root 存在 HANDOVER.md
- **THEN** AI SHALL 自動讀取 HANDOVER.md，並根據其指引讀取對應的 OpenSpec artifacts

#### Scenario: HANDOVER.md does not exist
- **WHEN** 新 session 開始且 project root 無 HANDOVER.md
- **THEN** 正常運作，不觸發任何恢復流程

## REMOVED Requirements

### Requirement: CLAUDE.md auto-detects HANDOVER.md

**Reason**: project `.claude/CLAUDE.md` 已搬遷至 repo root `AGENTS.md`。

**Migration**: 由 ADDED requirement「AGENTS.md auto-detects HANDOVER.md」承接，行為要求不變（規則宿主改為 root `AGENTS.md`）。
