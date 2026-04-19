---
name: openspec-tdd-verify
description: Execute the verification block of an OpenSpec task and mark it complete. Use after implementing a task to confirm it works before marking [x].
---

執行當前 task 的 `> 驗證：` 區塊，依結果決定是否 mark `[x]`。

**Input**: 當前 task 的描述，或從 tasks.md 中識別正在實作的 task。

**Steps**

1. **找到當前 task 的驗證區塊**

   從 tasks.md 中找到剛完成實作的 task，讀取其 `> 驗證：` 區塊。

   三種情境：
   - **有驗證指令** → 執行步驟 2
   - **標示「無法自動驗證」** → 執行步驟 4
   - **沒有 `> 驗證：` 區塊** → 執行步驟 5

2. **執行驗證指令**

   執行 `> 驗證：` 後的指令，捕捉輸出與 exit code，然後進入步驟 3。

3. **判斷結果**

   **通過**：
   - 將 tasks.md 中該 task 的 `- [ ]` 改為 `- [x]`
   - 輸出：`✓ 驗證通過 → marked [x]`
   - 結束

   **失敗**：
   - 不 mark `[x]`
   - 輸出失敗詳情（指令輸出、錯誤訊息）
   - 暫停並等待使用者指示
   - 結束

4. **無法自動驗證（已注記）**

   - 輸出：`⚠ 無法自動驗證：<注記內容>`
   - 將 task 的 `- [ ]` 改為 `- [x]`
   - 結束

5. **缺少驗證區塊**

   - 不 mark `[x]`
   - 輸出：
     ```
     ✗ 此 task 缺少 `> 驗證：` 區塊。

     請補上驗證條件，格式：
       > 驗證：<執行指令或驗收條件>

     若無法自動驗證：
       > 驗證：無法自動驗證（原因：<說明>）
     ```
   - 暫停並等待使用者補上後再繼續
   - 結束

