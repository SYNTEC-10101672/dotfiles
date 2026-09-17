# Delta Spec: artifact-review-gate

## MODIFIED Requirements

### Requirement: verdict 詞彙與修復循環上限

verdict SHALL 使用 `[OKAY]` / `[ITERATE]` / `[REJECT]` 三值，發起端（`/opsx:propose` 流程）與審查端 SHALL 使用同一組詞彙。ITERATE 時主 AI 修訂 artifacts 後重新送審；自動修復循環 SHALL 最多 2 輪，仍無法通過時 SHALL 升級詢問使用者而非繼續循環。

#### Scenario: 詞彙對齊

- **WHEN** 審查輸出 verdict
- **THEN** verdict 為 `[OKAY]`、`[ITERATE]`、`[REJECT]` 三者之一，`/opsx:propose` 流程的通過條件對應 `[OKAY]`

#### Scenario: 修復循環超過 2 輪升級

- **WHEN** 同一 change 已進行 2 輪 ITERATE 修復後第三次送審仍未通過
- **THEN** `/opsx:propose` 流程停止自動修復，向使用者呈現問題並等待決定
