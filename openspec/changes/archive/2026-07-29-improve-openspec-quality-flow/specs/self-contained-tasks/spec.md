## ADDED Requirements

### Requirement: Propose 階段必須區分 fact 與 decision

`openspec-propose` 在產出 artifact 時，MUST 區分「環境可查的事實（fact）」與「需要使用者決定的決策（decision）」：

- **Fact**（檔案路徑、API 名稱、IP/port、既有常數等環境可查者）MUST 由 AI 自行查 codebase / config / docs，將具體值 inline 寫入 artifact，不可用代名詞帶過
- **Decision**（演算法選擇、feature 範圍等需人類判斷者）MUST 透過 AskUserQuestion 詢問使用者
- 遇到 fact 但查 codebase 查不到時，MUST 詢問使用者（不可自行腦補代名詞）

`openspec-propose/SKILL.md` 第 108 行「If context is critically unclear, ask the user - but prefer making reasonable decisions to keep momentum」MUST 被刪除，並以本規則替換。

#### Scenario: 遇到服務 IP 時自行查 codebase

- **WHEN** propose 撰寫 tasks.md 過程中提到「測試控制器」（未帶具體 IP）
- **THEN** AI MUST 在 codebase（如 `config.dev.yaml`、`.env`、`docker-compose.yml`）查出具體 IP 並 inline 替換為「測試控制器 (127.0.0.1:8080, config.dev.yaml)」

#### Scenario: 遇到演算法選擇時詢問使用者

- **WHEN** propose 撰寫 design.md 時面臨「使用 Redis 還是 in-memory cache」的決策
- **THEN** AI MUST 透過 AskUserQuestion 詢問使用者，將答案記錄於 design.md 的 Decisions 段

#### Scenario: 查不到 fact 時不可腦補

- **WHEN** propose 撰寫 tasks.md 時提及某個外部資源（如第三方 API endpoint），且 codebase 內查無具體值
- **THEN** AI MUST 透過 AskUserQuestion 一次性列出所有查不到的項目詢問使用者，MUST NOT 自行填入代名詞或假設值

### Requirement: Propose 必須執行 Fact Lookup 階段

`openspec-propose` 在 Step 4（artifact 迴圈）完成後、Step 7（顯示狀態）之前，MUST 新增「Step 5 Fact Lookup」階段，對剛寫完的 artifact（特別是 tasks.md）逐條掃描找出模糊指代並處理。

掃描目標 MUST 包含：

- 指代詞：這個 / 那個 / 該 / 某 / 其
- 概念詞未具體化：控制器 / 服務 / 設定 / 函式 / 模組（未帶具體檔名或 API 名稱）
- 待填空：`<...>` / 適當的 / 對應的 / 相關的

對每個模糊點的處理順序：

1. 優先用 grep / glob / read 查 codebase（優先查 `.env` / `config.*.yaml` / `package.json` / entry files）
2. 查到 → inline 替換
3. 查不到 → 列清單透過 AskUserQuestion 詢問使用者
4. 跨 task 共用的環境事實 MUST 寫進 design.md 的 `### Context` 段（避免每個 task 重複寫）

#### Scenario: tasks.md 中所有代名詞都被替換

- **WHEN** Fact Lookup 階段完成
- **THEN** tasks.md 中 MUST 不存在任何未具體化的代名詞；每個被识别的模糊點必須是「已 inline 具體值」或「已標記為 decision 並詢問使用者」

#### Scenario: 跨 task 共用事實集中於 design.md

- **WHEN** Fact Lookup 發現多個 task 共用同一環境事實（如多個 task 都提及同一個 API endpoint）
- **THEN** 該事實 MUST 被寫入 design.md 的 `### Context` 段一次，task 內引用該段（如「見 Context」）

### Requirement: Propose 必須通過 Self-Containment Gate

`openspec-propose` 在 Step 5（Fact Lookup）完成後、Step 7（顯示狀態）之前，MUST 新增「Step 6 Self-Containment Gate」階段，模擬「未參與 session 對話的 fresh AI」視角對每個 task 檢查三項：

1. **檔案可定位**：具體路徑（如 `src/auth.ts`）或可定位描述（如「處理 login 的 service，在 `src/services/` 下」）
2. **變更具體**：具體 API / 行號 / 變更內容（不可是「重寫」「最佳化」「改善」這類抽象動詞）
3. **完成條件可檢查**：對應的 T* 可被執行，或有具體驗收標準（如「帶 invalid token 呼叫 POST /users 回 401」）

任一項未滿足 → MUST 回 Fact Lookup 階段補強該 task。

對「概念性 task」（如設計新結構、新流程），MUST 要求附具體 schema / pseudocode / 檔案結構，MUST NOT 只有 prose 敘述。

#### Scenario: 完成 Gate 後 tasks.md 可被 fresh AI 獨立執行

- **WHEN** Self-Containment Gate 通過所有 task
- **THEN** 一個未參與 session 對話的 fresh AI MUST 能讀完 tasks.md 後直接開始實作，無需回頭詢問 session context

#### Scenario: 抽象 task 被抓出補強

- **WHEN** Gate 發現某個 task 寫「重寫 handover 邏輯」（無具體檔案、行號、API）
- **THEN** 該 task MUST 被退回 Fact Lookup 補強，補上具體檔案路徑（如 `claude/commands/handover.md`）、變更前後內容、驗收條件

### Requirement: CLAUDE.md 必須記錄 self-containment 規範

`~/.claude/CLAUDE.md` 的「OpenSpec 規範」段（第 45 行起）MUST 新增以下兩條規範：

1. **禁代名詞**：寫 tasks.md 時不可用代名詞描述環境事實，必須用具體值（例：「測試控制器」要寫成「127.0.0.1:8080 (config.dev.yaml)」）
2. **design.md Context 段**：design.md 應包含 `### Context` 段落，集中放跨 task 共用的環境事實（服務 URL、檔案路徑、既有 API 等）

#### Scenario: CLAUDE.md 包含兩條新規範

- **WHEN** 讀取 `~/.claude/CLAUDE.md` 的「OpenSpec 規範」段
- **THEN** MUST 可見「禁代名詞」與「design.md Context 段」兩條規範文字
