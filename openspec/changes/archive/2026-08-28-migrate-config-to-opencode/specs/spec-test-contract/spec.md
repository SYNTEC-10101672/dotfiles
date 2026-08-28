# Delta Spec: spec-test-contract

## MODIFIED Requirements

### Requirement: apply 階段不重複生成測試項目

`openspec-apply-change` MUST NOT 在 apply 階段另行評估或生成新的 T\* 項目（原 step 5.5 unit test assessment 已移除）；apply 直接以 tasks.md 既有 T\* 走 Red → Green → Final 三相驗證。

#### Scenario: apply 開頭無測試評估互動

- **WHEN** 使用者啟動 `openspec-apply-change`
- **THEN** 流程不詢問「是否新增 T\* 項目」，直接進入 TDD 三相實作

#### Scenario: apply 檔案不含 step 5.5

- **WHEN** 檢視 `opencode/skills/openspec-apply-change/SKILL.md`
- **THEN** 不存在「Unit test assessment」段落
