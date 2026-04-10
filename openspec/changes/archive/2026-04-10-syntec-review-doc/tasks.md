## 1. 建立 Command 檔案

- [x] 1.1 確認 `.claude/commands/syntec/` 目錄存在，若無則建立
- [x] 1.2 建立 `.claude/commands/syntec/review-doc.md`，撰寫 command 的 metadata（name、description）
- [x] 1.3 實作：接受主文件 URL 參數，透過 Atlassian MCP `getConfluencePage` 取得頁面（cloudId: syntecclub.atlassian.net）
- [x] 1.4 實作：從對話 context 偵測補充 Confluence URL 並取得頁面；任一文件取得失敗則回報並停止
- [x] 1.5 實作：語意判斷略過行政資訊（作者/日期/ISSUE/簽核欄位/SOP說明/佔位文字），不依賴硬編碼章節名稱
- [x] 1.6 實作：各文件各章節 review，每個問題標記 [嚴重]/[中等]/[輕微]
- [x] 1.7 實作：輸出按「文件 → 章節」分組
- [x] 1.8 實作：跨文件比對——語意識別規格性質與測試性質內容，輸出覆蓋度分析與識別來源說明

## 2. 驗證

- [x] 2.1 以單一標準模板文件測試（MMI-7327）：確認略過行政章節、問題分級正確
- [x] 2.2 以主文件 + 補充文件測試：確認補充文件被正確偵測與讀取
- [x] 2.3 確認跨文件比對段落正確輸出，並說明識別到的規格與測試來源
- [x] 2.4 確認行政資訊性質的章節不產生 review 輸出
