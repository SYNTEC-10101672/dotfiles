## 為什麼

Code review 前需要先審查設計文件，但實際使用的文件不一定符合標準模板（R-RD13-00-01 v6）——實作者常會新建補充文件說明自己的議題，沒有固定格式。需要一個能處理任意文件結構的 review command，讓 Claude 讀取所有相關文件後，輸出分級問題清單並比對規格與測試的覆蓋度。

## 變更內容

- 新增 Claude Code custom command：`.claude/commands/syntec/review-doc.md`
- Command 接受一或多個 Confluence URL（第一個為主文件，其餘為補充文件）
- 不綁定特定章節名稱，透過語意判斷略過行政資訊（作者、日期、簽核欄位等）
- 各文件各章節 review，輸出按文件/章節分組，每項標記 `[嚴重]`/`[中等]`/`[輕微]`
- 跨文件比對：從所有文件中識別「規格/需求」與「測試/驗收」內容，檢查覆蓋度

## 功能範疇

### 新增功能
- `syntec-review-doc-command`：`/syntec:review-doc` Claude Code custom command 的完整行為規格，包含多文件輸入、語意略過規則、嚴重程度定義、輸出格式、跨文件覆蓋度比對

### 修改功能

（無）

## 影響範圍

- 新增檔案：`.claude/commands/syntec/review-doc.md`
- 依賴：Atlassian MCP plugin（已安裝），cloudId = `syntecclub.atlassian.net`
- 不影響任何程式碼或既有設定
