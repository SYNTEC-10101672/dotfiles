## ADDED Requirements

### Requirement: 全域 CLAUDE.md 包含 OpenSpec TDD 規範
全域 `claude/CLAUDE.md` SHALL 包含 OpenSpec 規範段落，規定：
1. tasks.md 每個 task 必須有 `> 驗證：` 區塊
2. 實作完每個 task 後，必須使用 `openspec-tdd-verify` skill 執行驗證，通過才 mark `[x]`

#### Scenario: Claude 產生 tasks.md
- **WHEN** Claude 為 OpenSpec change 產生 tasks.md
- **THEN** 每個 task 包含 `> 驗證：` 區塊

#### Scenario: Claude 完成 task 實作
- **WHEN** Claude 透過 opsx:apply 完成一個 task 的實作
- **THEN** Claude 呼叫 `openspec-tdd-verify` skill 執行驗證，通過後才 mark `[x]`
