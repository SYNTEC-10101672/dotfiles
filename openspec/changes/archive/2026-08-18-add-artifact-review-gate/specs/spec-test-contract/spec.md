# spec-test-contract Delta Spec

## MODIFIED Requirements

### Requirement: T\* 測試項目於 propose 階段生成

`openspec-propose` 生成 `tasks.md` 時，MUST 同時產出 `## Tests` section 的 T\* 測試項目（T1、T2…，各含 Command / Expected），使驗收契約隨所有 artifacts 一併接受 artifact review gate（`openspec-artifact-review` skill）與人工 review。docs-only change 若無可執行驗證，MUST 在 tasks.md 記載豁免理由。

#### Scenario: propose 產出的 tasks.md 含 T\*

- **WHEN** `openspec-propose` 完成 `tasks.md`
- **THEN** 檔案包含 `## Tests` section 且每個 T\* 項目有具體 Command 與 Expected

#### Scenario: T\* 隨 artifacts 通過 review

- **WHEN** propose 進入 artifact review gate 與人工 review
- **THEN** review 對象包含 `## Tests` section（T\* 不是事後補件）
