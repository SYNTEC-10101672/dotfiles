# Delta Spec: self-contained-tasks

## ADDED Requirements

### Requirement: AGENTS.md 必須記錄 self-containment 規範

全域指示檔 `opencode/AGENTS.md`（部署為 `~/.config/opencode/AGENTS.md`）的「OpenSpec 規範」段 MUST 包含以下兩條規範：

1. **禁代名詞**：寫 tasks.md 時不可用代名詞描述環境事實，必須用具體值（例：「測試控制器」要寫成「127.0.0.1:8080 (config.dev.yaml)」）
2. **design.md Context 段**：design.md 應包含 `### Context` 段落，集中放跨 task 共用的環境事實（服務 URL、檔案路徑、既有 API 等）

#### Scenario: AGENTS.md 包含兩條規範
- **WHEN** 讀取 `opencode/AGENTS.md` 的「OpenSpec 規範」段
- **THEN** MUST 可見「禁代名詞」與「design.md Context 段」兩條規範文字

### Requirement: 全域指示檔包含 OpenSpec TDD 規範

全域指示檔 `opencode/AGENTS.md`（部署為 `~/.config/opencode/AGENTS.md`）SHALL 包含 OpenSpec 規範段落，規定：
1. tasks.md 每個 task 必須有 `> 驗證：` 區塊
2. 實作完每個 task 後，必須使用 `openspec-tdd-verify` skill 執行驗證，通過才 mark `[x]`

#### Scenario: 產生 tasks.md
- **WHEN** AI 為 OpenSpec change 產生 tasks.md
- **THEN** 每個 task 包含 `> 驗證：` 區塊

#### Scenario: 完成 task 實作
- **WHEN** AI 透過 opsx:apply 完成一個 task 的實作
- **THEN** AI 呼叫 `openspec-tdd-verify` skill 執行驗證，通過後才 mark `[x]`

## REMOVED Requirements

### Requirement: CLAUDE.md 必須記錄 self-containment 規範

**Reason**: `~/.claude/CLAUDE.md` 隨 `claude/CLAUDE.md` 搬遷改名為 `opencode/AGENTS.md`（部署於 `~/.config/opencode/AGENTS.md`）。

**Migration**: 由 ADDED requirement「AGENTS.md 必須記錄 self-containment 規範」承接，規範內容不變。
