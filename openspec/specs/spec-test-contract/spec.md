# spec-test-contract

openspec-propose 與 openspec-apply-change 之間的 T* 測試項目契約：T* 於 propose 階段生成，apply 階段不重複生成。

## Purpose

定義 T* 測試項目的生成時機與責任歸屬：`openspec-propose` 負責在 propose 階段產出 `## Tests` section 的 T\* 項目，`openspec-apply-change` 直接使用既有 T\* 走 TDD 三相驗證，不另行生成。

## Requirements

### Requirement: T\* 測試項目於 propose 階段生成

`openspec-propose` 生成 `tasks.md` 時，MUST 同時產出 `## Tests` section 的 T\* 測試項目（T1、T2…，各含 Command / Expected），使驗收契約隨所有 artifacts 一併接受 artifact review gate（`openspec-artifact-review` skill）與人工 review。docs-only change 若無可執行驗證，MUST 在 tasks.md 記載豁免理由。

#### Scenario: propose 產出的 tasks.md 含 T\*

- **WHEN** `openspec-propose` 完成 `tasks.md`
- **THEN** 檔案包含 `## Tests` section 且每個 T\* 項目有具體 Command 與 Expected

#### Scenario: T\* 隨 artifacts 通過 review

- **WHEN** propose 進入 artifact review gate 與人工 review
- **THEN** review 對象包含 `## Tests` section（T\* 不是事後補件）

### Requirement: apply 階段不重複生成測試項目

`openspec-apply-change` MUST NOT 在 apply 階段另行評估或生成新的 T\* 項目（原 step 5.5 unit test assessment 已移除）；apply 直接以 tasks.md 既有 T\* 走 Red → Green → Final 三相驗證。

#### Scenario: apply 開頭無測試評估互動

- **WHEN** 使用者啟動 `openspec-apply-change`
- **THEN** 流程不詢問「是否新增 T\* 項目」，直接進入 TDD 三相實作

#### Scenario: apply 檔案不含 step 5.5

- **WHEN** 檢視 `claude/skills/openspec-apply-change/SKILL.md`
- **THEN** 不存在「Unit test assessment」段落
