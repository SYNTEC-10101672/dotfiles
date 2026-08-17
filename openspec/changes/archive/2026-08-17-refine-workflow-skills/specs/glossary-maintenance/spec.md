# Delta Spec: glossary-maintenance

## ADDED Requirements

### Requirement: apply 前階段即時維護 CONTEXT.md

`openspec-explore` 與 `openspec-propose` 在各自階段釐清領域詞彙時，MUST 即時寫入該專案的 `CONTEXT.md`（依 `domain-modeling` 的 CONTEXT-FORMAT.md 格式；檔案不存在時 lazily 建立）。`grill` 階段經 `grill-with-docs` → `domain-modeling` 既有行為維持不變。

#### Scenario: explore 釐清詞彙即寫入

- **WHEN** `openspec-explore` session 中使用者與 AI 對某領域詞彙達成明確定義
- **THEN** 該詞彙即時寫入專案 `CONTEXT.md`，而非 session 結束才補

#### Scenario: propose 釐清詞彙即寫入

- **WHEN** `openspec-propose` 的 Fact Lookup 或 artifact 撰寫過程釐清領域詞彙
- **THEN** 該詞彙即時寫入專案 `CONTEXT.md`

### Requirement: apply 階段禁止寫入 CONTEXT.md

`openspec-apply-change` 執行期間 MUST NOT 寫入或更新 `CONTEXT.md`，以避免任務執行被文件維護中斷。apply 期間發現的新詞彙由後續 change 的 explore / grill / propose 階段捕獲。

#### Scenario: apply 不中斷寫 glossary

- **WHEN** `openspec-apply-change` 實作任務時發現新的領域詞彙
- **THEN** 流程不因此暫停或寫入 `CONTEXT.md`，任務繼續執行

### Requirement: domain-modeling 不產生 ADR

`domain-modeling` skill SHALL NOT 提議、生成或維護 ADR（Architecture Decision Record）；架構決策一律記錄於各 change 的 `design.md`。`docs/adr/` 目錄與 `ADR-FORMAT.md` 不再屬於此 skill 的產出。

#### Scenario: domain-modeling 無 ADR 引用

- **WHEN** 檢視 `claude/skills/domain-modeling/SKILL.md`
- **THEN** 內容不含任何 ADR 相關段落或連結

#### Scenario: grill-with-docs 描述與行為一致

- **WHEN** 檢視 `claude/skills/grill-with-docs/SKILL.md` 的 description
- **THEN** 不含 ADR 字樣，僅保留 glossary（CONTEXT.md）維護
