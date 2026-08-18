# artifact-review-gate Delta Spec

## ADDED Requirements

### Requirement: 審查準則為 blocker-only

`openspec-artifact-review` skill 的審查準則 SHALL 移植 Momus 的 blocker-finder 紀律：approval bias（有疑慮時傾向通過）、只將 true blocker 列為問題（referenced 檔案不存在、任務完全無法起頭、artifacts 內部矛盾使計畫無法遵循）、不評論設計優劣或 edge case 完整度。單次 ITERATE 或 REJECT SHALL 最多列 3 個 issues。

#### Scenario: 非 blocker 不阻擋

- **WHEN** 審查報告中出現「建議補充 edge case」「措辭可以更清楚」等非 blocker 意見
- **THEN** 該意見不構成 ITERATE 或 REJECT 的理由，verdict 仍為 `[OKAY]`

#### Scenario: issues 數量上限

- **WHEN** 審查發現超過 3 個問題
- **THEN** 報告只列最關鍵的 3 個

### Requirement: 審查涵蓋 OpenSpec 格式與 T\* 契約

審查 SHALL 涵蓋 OpenSpec 專屬檢查：delta spec 格式（`## ADDED Requirements` / `## MODIFIED Requirements` 等 section header、`### Requirement:` 與 `#### Scenario:` 結構、WHEN/THEN 情境）、tasks.md 的 `## Tests` section 中每個 T\* 項目 MUST 含具體 `> Command:` 與 `> Expected:`（或記載豁免理由）。缺 T\* 契約或格式錯誤 SHALL 視為 blocker。

#### Scenario: delta spec 格式錯誤被擋下

- **WHEN** delta spec 的 Scenario 使用 3 個 `#` 而非 `####`
- **THEN** 審查將其列為 blocker issue

#### Scenario: T\* 缺 Command/Expected 被擋下

- **WHEN** tasks.md 的 T\* 項目缺少 `> Command:` 或 `> Expected:`，且無豁免理由記載
- **THEN** 審查將其列為 blocker issue

### Requirement: 以 codebase 驗證 reference 且不做外部驗證

審查者 SHALL 以本地 codebase 驗證 artifacts 中的 reference（檔案路徑存在、宣稱的內容相符、引用的 pattern 真實示範於該處）。外部事實（套件版本、API 行為）SHALL NOT 觸發 websearch 或 MCP 查證 — 此 gate 不依賴任何外部驗證工具。

#### Scenario: 引用不存在的檔案被擋下

- **WHEN** design.md 引用 `claude/skills/nonexistent/SKILL.md` 作為依據
- **THEN** 審查者以本地檔案系統確認不存在後，列為 blocker issue

#### Scenario: 不使用外部查證

- **WHEN** artifacts 宣稱某外部套件的行為而無法以本地 codebase 驗證
- **THEN** 審查者不呼叫 websearch / MCP，該聲明不因「無法外部驗證」被列為 blocker

### Requirement: 審查者 read-only、修改由主 AI 執行

審查者 SHALL 為 read-only — 只產出 verdict 與 issues 報告，MUST NOT 寫入、編輯或刪除任何檔案。修訂 flagged artifacts 的工作由發起 propose 的主 AI 執行，修訂後重新送審。

#### Scenario: 審查輸出不含檔案修改

- **WHEN** 審查完成並輸出 ITERATE 報告
- **THEN** 工作區內任何檔案（含被審的 artifacts）內容未遭審查者變更

### Requirement: verdict 詞彙與修復循環上限

verdict SHALL 使用 `[OKAY]` / `[ITERATE]` / `[REJECT]` 三值，發起端（`openspec-propose`）與審查端 SHALL 使用同一組詞彙。ITERATE 時主 AI 修訂 artifacts 後重新送審；自動修復循環 SHALL 最多 2 輪，仍無法通過時 SHALL 升級詢問使用者而非繼續循環。

#### Scenario: 詞彙對齊

- **WHEN** 審查輸出 verdict
- **THEN** verdict 為 `[OKAY]`、`[ITERATE]`、`[REJECT]` 三者之一，`openspec-propose` 的通過條件對應 `[OKAY]`

#### Scenario: 修復循環超過 2 輪升級

- **WHEN** 同一 change 已進行 2 輪 ITERATE 修復後第三次送審仍未通過
- **THEN** `openspec-propose` 停止自動修復，向使用者呈現問題並等待決定

### Requirement: 重新送審時從 disk 重讀 artifacts

審查者於每次被 invoke（含 re-invoke）時 SHALL 從 disk 重新讀取被審 artifacts 的當前內容，MUST NOT 依賴先前對話中讀過的版本。先前 verdict 對新一輪審查不具約束力。

#### Scenario: re-invoke 反映修訂後內容

- **WHEN** 主 AI 修訂 tasks.md 後重新送審
- **THEN** 審查者讀到的是 disk 上的新版內容，verdict 基於新版判定
