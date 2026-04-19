## ADDED Requirements

### Requirement: 驗證區塊格式
tasks.md 中每個 task SHALL 包含 `> 驗證：` 區塊，定義該 task 的驗收條件。無法自動驗證時 SHALL 注記原因。

格式：
```markdown
- [ ] Task 描述
  > 驗證：<執行指令或驗收條件>
```

無法驗證時：
```markdown
- [ ] Task 描述
  > 驗證：無法自動驗證（原因：<說明>）
```

#### Scenario: 正常 task 有驗證指令
- **WHEN** Claude 產生 tasks.md
- **THEN** 每個 task 下方有 `> 驗證：` 區塊，包含可執行的驗收指令

#### Scenario: 無法自動驗證的 task
- **WHEN** task 的驗收無法透過指令自動執行（如需人工確認）
- **THEN** `> 驗證：` 區塊標示「無法自動驗證」並說明原因

### Requirement: openspec-tdd-verify skill 執行驗證
`openspec-tdd-verify` skill SHALL 讀取當前 task 的 `> 驗證：` 區塊，執行驗證，並依結果決定是否 mark `[x]`。

#### Scenario: 驗證通過
- **WHEN** 執行 `> 驗證：` 指令後結果為成功
- **THEN** skill 將 task `- [ ]` 改為 `- [x]`，繼續下一個 task

#### Scenario: 驗證失敗
- **WHEN** 執行 `> 驗證：` 指令後結果為失敗
- **THEN** skill 回報失敗詳情，暫停並等待使用者指示，不 mark `[x]`

#### Scenario: 無法自動驗證（已注記）
- **WHEN** `> 驗證：` 區塊標示「無法自動驗證」
- **THEN** skill log 注記內容，mark `[x]`（帶注記），繼續下一個 task

#### Scenario: 缺少驗證區塊
- **WHEN** task 沒有 `> 驗證：` 區塊
- **THEN** skill 暫停，要求使用者補上驗證區塊或注記原因，不 mark `[x]`
