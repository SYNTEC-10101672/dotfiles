---
name: openspec-tdd-verify
description: Execute TDD verification for OpenSpec tasks using T* items with structured 指令/預期 fields. Supports Red phase (before impl), Green phase (after each task), and Final phase (all tests).
---

執行 tasks.md 中 T* 測試項目的驗證，依結果決定是否 mark `[x]`。

**Input**: 執行階段（Red / Green / Final）與對應的 T* 編號，或從上下文推斷。

**Steps**

1. **識別執行階段與目標 T* 項目**

   從上下文判斷執行階段：
   - **Red phase**：apply 開始前，執行全部 T* 以確認尚未通過
   - **Green phase**：某個實作 task 完成後，執行對應的 T*
   - **Final phase**：全部實作完成後，執行全部 T* 確認都通過

   從 tasks.md 的 `## 測試` 區塊讀取目標 T* 項目。

   **若 tasks.md 使用舊的 `> 驗證：` inline 格式**：
   - 提示此格式已過時
   - 輸出：`⚠ tasks.md 使用舊版 \`> 驗證：\` 格式，請更新為 T* 格式（\`## 測試\` 區塊，含 \`> 指令：\` 與 \`> 預期：\`）後再執行驗證。`
   - 結束

2. **AI 自評驗證可行性**

   對每個 T* 項目，先評估 `> 指令：` 是否可直接執行：
   - **明確的 shell 指令** → 直接執行，跳至步驟 3
   - **涉及 UI、網路、特殊環境** → 提出 1-2 個替代驗證方案詢問使用者（如 log 檢查、API call、啟動本地服務），等待確認後決定如何驗證
   - **T* 含 `> 備註：手動驗證`** → 跳至步驟 5

3. **執行驗證指令**

   執行 T* 的 `> 指令：`，捕捉完整輸出與 exit code。

4. **比對預期結果**

   將指令輸出與 `> 預期：` 進行比對：

   **Red phase 通過（= 測試 fail，符合預期）**：
   - 繼續下一個 T*
   - 若某個 T* 在 Red phase 已通過（= 測試 pass，不符合 Red phase 預期）：
     - 輸出警告：`⚠ T<n> 在 Red phase 已通過，實作前測試不應通過。請確認是否繼續。`
     - 詢問使用者是否繼續

   **Green / Final phase 通過（= 測試 pass）**：
   - 將 tasks.md 中該 T* 的 `- [ ]` 改為 `- [x]`
   - 輸出：`✓ T<n> 通過 → marked [x]`

   **Green / Final phase 失敗（= 測試 fail）**：
   - 不 mark `[x]`
   - 輸出失敗詳情：指令輸出與 `> 預期：` 的差異
   - 暫停並等待使用者指示

5. **手動驗證（確認無法自動執行）**

   - 輸出：`⚠ 手動驗證：<描述使用者需確認的項目>`
   - 將 T* 的 `- [ ]` 改為 `- [x]`（帶注記）
   - 繼續下一個 T*

6. **輸出摘要**

   執行完所有目標 T* 後，輸出摘要：
   ```
   ## 驗證摘要（<phase> phase）

   ✓ T1 通過
   ✓ T2 通過
   ✗ T3 失敗（見上方詳情）

   通過：2/3　失敗：1/3
   ```
