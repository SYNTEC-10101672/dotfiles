## ADDED Requirements

### Requirement: permission.read 阻擋 AI 讀取敏感檔案

OpenCode global config（`opencode/opencode.json` 的 `permission.read`）SHALL deny AI 讀取敏感檔案路徑，並允許 example template 例外：`"**/.env": "deny"`、`"**/.env.*": "deny"`、`"**/.credentials.json": "deny"`、`"**/.env.example": "allow"`，其余 `"*": "allow"`。規則排序 SHALL 遵守 last-matching-rule-wins（`allow` 例外必須排在 deny 之後）。

#### Scenario: AI 嘗試讀取 .env 被 deny

- **WHEN** AI 在任何 project 執行 read tool 存取 `.env` 或 `.env.local` 等符合 `**/.env` / `**/.env.*` 的路徑
- **THEN** 該 read 呼叫 SHALL 被 permission 系統拒絕

#### Scenario: AI 讀取 .env.example 被允許

- **WHEN** AI 執行 read tool 存取 `.env.example`
- **THEN** 該 read 呼叫 SHALL 被允許（template 檔案不含真實金鑰）

#### Scenario: AI 讀取一般檔案不受影響

- **WHEN** AI 執行 read tool 存取不符合 deny pattern 的檔案
- **THEN** 該 read 呼叫 SHALL 被允許

### Requirement: guard plugin 在 git commit 前掃描 staged 內容

`opencode/plugins/guard.ts` SHALL 透過 `tool.execute.before` hook 攔截 bash tool，當 `output.args.command` 包含 `git commit` 子字串時，於指令執行前執行 `gitleaks protect --staged --redact` 掃描 staged 內容。掃描發現 secret 時 SHALL `throw` 阻止該 bash tool call，錯誤訊息 SHALL 包含 gitleaks 的 redacted 輸出（finding 描述與檔案位置，不含 secret 本體）。掃描乾淨時 SHALL 放行指令不干擾。

#### Scenario: staged 內容含 AWS key 被 block

- **WHEN** AI 執行 `git commit -m "add config"`，且 staged 檔案內容含 `AKIA` 開頭的 AWS access key
- **THEN** 該 bash tool call SHALL 被 throw 阻止，commit 不執行
- **THEN** 錯誤訊息 SHALL 含 finding 位置且不含 secret 明文（redacted）

#### Scenario: staged 內容乾淨時正常 commit

- **WHEN** AI 執行 `git commit -m "docs: update"`，且 staged 內容無已知 secret 格式
- **THEN** 該 bash tool call SHALL 正常執行

#### Scenario: 非 git commit 指令不觸發掃描

- **WHEN** AI 執行 `git status` 或 `ls` 等不含 `git commit` 的 bash 指令
- **THEN** guard plugin SHALL 不做任何攔截或掃描

#### Scenario: git commit --amend 也被掃描

- **WHEN** AI 執行 `git commit --amend`，且 staged 內容含 PEM private key
- **THEN** 該 bash tool call SHALL 被 throw 阻止

### Requirement: gitleaks 缺失時 fail-closed

`guard.ts` 執行掃描前 SHALL 檢查 `gitleaks` binary 是否存在（以外部指令如 `gitleaks version` 檢查——opencode plugin 的 shell 環境不支援 `command -v` builtin）。不存在時 SHALL `throw` 阻止該 `git commit` tool call，錯誤訊息 SHALL 說明 gitleaks 未安裝並提供安裝指引。此行為 SHALL 對每個被攔的 commit 一致（不因重試而放行）。

#### Scenario: 機器無 gitleaks 時 AI 的 commit 被擋

- **WHEN** 機器上沒有 `gitleaks` binary，AI 執行 `git commit -m "..."`
- **THEN** 該 bash tool call SHALL 被 throw 阻止
- **THEN** 錯誤訊息 SHALL 指示安裝 gitleaks

#### Scenario: 安裝 gitleaks 後恢復正常

- **WHEN** gitleaks 已安裝且 staged 內容乾淨
- **THEN** AI 的 `git commit` SHALL 正常執行

### Requirement: git push 需人工確認

OpenCode global config（`opencode/opencode.json` 的 `permission.bash`）SHALL 設定 `"git push *": "ask"`，使 AI 執行的 `git push` 需經使用者人工確認（permission.asked UI）才會執行。

#### Scenario: AI 執行 git push 跳出確認

- **WHEN** AI 執行 `git push origin main`
- **THEN** SHALL 觸發 permission.asked，由使用者決定允許或拒絕

#### Scenario: 使用者否決則 push 不執行

- **WHEN** permission.asked 顯示且使用者選擇拒絕
- **THEN** 該 `git push` SHALL 不執行
