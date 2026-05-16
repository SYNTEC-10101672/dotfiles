## ADDED Requirements

### Requirement: Handover detects active OpenSpec change
`/handover` SHALL 在開始時偵測是否有 active OpenSpec change，並據此決定生成模式。

#### Scenario: Active change exists
- **WHEN** 執行 `/handover` 且 `openspec/changes/` 下有含 `proposal.md` 的目錄
- **THEN** SHALL 使用薄入口模式生成 HANDOVER.md

#### Scenario: No active change
- **WHEN** 執行 `/handover` 且 `openspec/changes/` 下無 active change
- **THEN** SHALL 使用完整模式生成 HANDOVER.md

#### Scenario: Multiple active changes
- **WHEN** 執行 `/handover` 且有多個 active change
- **THEN** SHALL 詢問使用者要針對哪個 change 進行交接

### Requirement: Thin mode HANDOVER.md uses progressive disclosure
薄入口模式下，HANDOVER.md SHALL 保持簡短，使用漸進式披露指向 OpenSpec artifacts。

#### Scenario: Thin mode HANDOVER.md structure
- **WHEN** 以薄入口模式生成 HANDOVER.md
- **THEN** SHALL 包含：active change 指標、本次 session 簡述、當前進度（tasks 完成數/總數）、下一步、context 指引（指向 proposal.md/design.md/tasks.md）
- **THEN** 總長度 SHALL 不超過一頁（約 50 行以內）

### Requirement: Full mode HANDOVER.md carries complete context
完整模式下，HANDOVER.md SHALL 自帶完整 context，不依賴外部 artifacts。

#### Scenario: Full mode HANDOVER.md structure
- **WHEN** 以完整模式生成 HANDOVER.md
- **THEN** SHALL 包含：session 摘要、已完成工作、剩餘工作（P0/P1/P2）、重要決策、開放問題、下一步

#### Scenario: Exploration has crystallized
- **WHEN** 以完整模式生成且探索已有明確方向
- **THEN** SHALL 在下一步中建議使用 `/opsx:propose` 正式化結論

### Requirement: CLAUDE.md auto-detects HANDOVER.md
project `.claude/CLAUDE.md` SHALL 包含一條規則：session 開始時若偵測到 HANDOVER.md 存在，自動讀取並根據指引恢復 context。

#### Scenario: HANDOVER.md exists at session start
- **WHEN** 新 session 開始且 project root 存在 HANDOVER.md
- **THEN** AI SHALL 自動讀取 HANDOVER.md，並根據其指引讀取對應的 OpenSpec artifacts

#### Scenario: HANDOVER.md does not exist
- **WHEN** 新 session 開始且 project root 無 HANDOVER.md
- **THEN** 正常運作，不觸發任何恢復流程

### Requirement: HANDOVER.md excludes redundant sections
HANDOVER.md SHALL 不包含 Modified Files、Reference Commands、Dependencies 等可從 git 取得的區段。

#### Scenario: Generating HANDOVER.md
- **WHEN** 生成 HANDOVER.md（任一模式）
- **THEN** SHALL 不包含 Modified Files、Reference Commands、Dependencies、Links and Resources 區段
