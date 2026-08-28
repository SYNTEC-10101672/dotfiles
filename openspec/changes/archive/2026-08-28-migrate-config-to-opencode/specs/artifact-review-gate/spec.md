# Delta Spec: artifact-review-gate

## MODIFIED Requirements

### Requirement: 以 codebase 驗證 reference 且不做外部驗證

審查者 SHALL 以本地 codebase 驗證 artifacts 中的 reference（檔案路徑存在、宣稱的內容相符、引用的 pattern 真實示範於該處）。外部事實（套件版本、API 行為）SHALL NOT 觸發 websearch 或 MCP 查證 — 此 gate 不依賴任何外部驗證工具。

#### Scenario: 引用不存在的檔案被擋下

- **WHEN** design.md 引用 `opencode/skills/nonexistent/SKILL.md` 作為依據
- **THEN** 審查者以本地檔案系統確認不存在後，列為 blocker issue

#### Scenario: 不使用外部查證

- **WHEN** artifacts 宣稱某外部套件的行為而無法以本地 codebase 驗證
- **THEN** 審查者不呼叫 websearch / MCP，該聲明不因「無法外部驗證」被列為 blocker
