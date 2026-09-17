# Delta Spec: glossary-maintenance

## MODIFIED Requirements

### Requirement: apply 前階段即時維護 CONTEXT.md

`/opsx:explore` 流程（`opencode/commands/opsx/explore.md`）與 `/opsx:propose` 流程（`opencode/commands/opsx/propose.md`）在各自階段釐清領域詞彙時，MUST 即時寫入該專案的 `CONTEXT.md`（依 `domain-modeling` 的 CONTEXT-FORMAT.md 格式；檔案不存在時 lazily 建立）。`grill` 階段經 `grill-with-docs` → `domain-modeling` 既有行為維持不變。

#### Scenario: explore 釐清詞彙即寫入

- **WHEN** `/opsx:explore` session 中使用者與 AI 對某領域詞彙達成明確定義
- **THEN** 該詞彙即時寫入專案 `CONTEXT.md`，而非 session 結束才補

#### Scenario: propose 釐清詞彙即寫入

- **WHEN** `/opsx:propose` 流程的 Fact Lookup 或 artifact 撰寫過程釐清領域詞彙
- **THEN** 該詞彙即時寫入專案 `CONTEXT.md`

### Requirement: apply 階段禁止寫入 CONTEXT.md

`/opsx:apply` 流程（`opencode/commands/opsx/apply.md`）執行期間 MUST NOT 寫入或更新 `CONTEXT.md`，以避免任務執行被文件維護中斷。apply 期間發現的新詞彙由後續 change 的 explore / grill / propose 階段捕獲。

#### Scenario: apply 不中斷寫 glossary

- **WHEN** `/opsx:apply` 流程實作任務時發現新的領域詞彙
- **THEN** 流程不因此暫停或寫入 `CONTEXT.md`，任務繼續執行
