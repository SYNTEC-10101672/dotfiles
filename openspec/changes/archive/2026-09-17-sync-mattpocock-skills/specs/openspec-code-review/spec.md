# Delta: openspec-code-review（capability 退休）

## REMOVED Requirements

### Requirement: 新增 openspec-code-review skill
- **Reason**: skill 由 upstream verbatim 的 `code-review` skill 取代（更名 + 內容升級為 Matt 最新版）。
- **Migration**: 見 `specs/code-review/spec.md` 的「code-review skill 為 upstream verbatim」requirement。

### Requirement: Apply 完成實作後必須觸發 code review
- **Reason**: contract 平移至 `code-review` capability；invocation 對象改為 `code-review` skill，適配資訊（spec source、fixed point、無 tracker）改由 apply.md 呼叫處提供。
- **Migration**: 見 `specs/code-review/spec.md` 的「opsx:apply 完成實作後必須觸發 code review」requirement。

### Requirement: Code review 必須以雙軸平行 sub-agents 執行
- **Reason**: 雙軸平行 sub-agents 的行為由 upstream `code-review` skill 本體定義（verbatim），不再以 spec 重述 skill 內容。
- **Migration**: 該行為由 `specs/code-review/spec.md` 的 verbatim requirement 間接保證（skill 內建雙軸平行流程）。

### Requirement: Standards 軸必須使用 documented repo standards + Fowler 12 baseline
- **Reason**: Fowler 12 smells 於 upstream 最新版 skill 內含完整定義（what it is → how to fix），規則（repo standard 蓋過 baseline、heuristic 非 hard violation、略過 tooling 已強制者）由 skill 本體承載。
- **Migration**: 同上，由 verbatim requirement 保證。

### Requirement: Spec 軸必須對比 OpenSpec change artifacts
- **Reason**: 比對來源改由 apply.md 呼叫處注入（D2 call-site 適配），skill 不再寫死 OpenSpec 路徑。
- **Migration**: 見 `specs/code-review/spec.md` 的「opsx:apply 完成實作後必須觸發 code review」requirement（適配資訊第 1 項）。

### Requirement: Fix Loop 必須重跑 Final phase 測試
- **Reason**: contract 原文平移。
- **Migration**: 見 `specs/code-review/spec.md` 的同名 requirement。

### Requirement: AGENTS.md 必須記錄 apply 後必跑 code review 規範
- **Reason**: contract 平移，skill 名改為 `code-review`。
- **Migration**: 見 `specs/code-review/spec.md` 的同名 requirement。
