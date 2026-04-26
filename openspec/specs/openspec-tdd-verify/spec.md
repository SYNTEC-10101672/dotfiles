## MODIFIED Requirements

### Requirement: 驗證區塊格式
tasks.md 中的驗收條件 SHALL 以獨立 T* 測試項目呈現（`## 測試` 區塊），而非 inline `> 驗證：` blockquote。T* 項目包含 `> 指令：` 與 `> 預期：` 兩個結構化欄位。

格式：
```markdown
## 測試

- [ ] T1 描述驗收條件
  > 指令：`<可執行指令>`
  > 預期：<預期輸出或行為>
```

#### Scenario: tasks.md 包含 T* 格式的測試項目
- **WHEN** openspec-tdd-verify skill 執行
- **THEN** skill 讀取 `## 測試` 區塊中的 T* 項目，提取 `> 指令：` 執行，並以 `> 預期：` 判斷結果

#### Scenario: tasks.md 使用舊的 `> 驗證：` 格式
- **WHEN** tasks.md 仍使用 `> 驗證：` inline blockquote
- **THEN** skill 提示此格式已過時，建議使用者更新為 T* 格式，不自動執行舊格式驗證

### Requirement: openspec-tdd-verify skill 執行 TDD 驗證流程
`openspec-tdd-verify` skill SHALL 執行 T* 項目的驗證，依結果 mark `[x]`；SHALL 在開始前先讀取全部 T* 項目（Red phase 確認），實作完成後再次執行（Green phase 確認）。

#### Scenario: Red phase——實作前確認測試 fail
- **WHEN** opsx:apply 開始執行，在任何實作前呼叫 tdd-verify（Red phase）
- **THEN** 執行所有 T* 的 `> 指令：`，預期結果與 `> 預期：` 不符（fail），確認測試尚未通過；若某個 T* 在 Red phase 已通過，回報並詢問使用者是否繼續

#### Scenario: Green phase——實作後確認測試 pass
- **WHEN** 對應的實作 task 完成後，呼叫 tdd-verify 執行對應 T*
- **THEN** 執行該 T* 的 `> 指令：`，結果符合 `> 預期：`（pass），mark T* `[x]`

#### Scenario: 驗證失敗
- **WHEN** 執行 T* 的 `> 指令：` 後結果不符合 `> 預期：`
- **THEN** skill 回報失敗詳情（指令輸出、與預期的差異），暫停並等待使用者指示，不 mark `[x]`

### Requirement: AI 自評驗證可行性
`openspec-tdd-verify` skill SHALL 在執行前先評估每個 T* 是否可自動驗證；若不確定，SHALL 提出 1-2 個可能方案與使用者討論，而非直接標注「無法自動驗證」。

#### Scenario: AI 可直接執行驗證
- **WHEN** T* 的 `> 指令：` 是明確的 shell 指令
- **THEN** skill 直接執行，不需詢問

#### Scenario: AI 不確定如何驗證
- **WHEN** T* 的描述涉及 UI 操作、網路服務、或需要特殊環境
- **THEN** skill 提出 1-2 個替代驗證方案（如 log 檢查、API call、啟動本地服務）並詢問使用者，不自行決定「無法驗證」

#### Scenario: 確認無法自動驗證
- **WHEN** 與使用者討論後確認無法自動執行
- **THEN** skill 輸出 `⚠ 手動驗證：<描述使用者需確認的項目>`，mark T* `[x]`（帶注記），繼續下一個 T*
