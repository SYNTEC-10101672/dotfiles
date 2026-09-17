# opencode-commit-gate

AI git commit 授權閘：未授權 session 的 `git commit` 一律阻擋，`/commit` 授權後放行，授權 state 隨 session 與非 `/commit` 指令清除。

## Purpose

定義 `opencode/plugins/commit-gate.ts` 的阻擋、放行與 state 生命週期行為，確保 AI 只能在使用者執行 `/commit` 後的 session 中 commit，並以阻擋訊息引導任務繼續而非重試。

## Requirements

### Requirement: 未授權 session 的 git commit 阻擋

`opencode/plugins/commit-gate.ts` SHALL 透過 `tool.execute.before` hook 攔截 bash tool，當指令字串匹配 `git commit` subcommand（regex `/\bgit\s+(?:-\S+\s+(?:\S+\s+)?)*commit(?![\w-])/`，涵蓋 `git -C <path> commit`、`&&`/`;` chain、env prefix 形狀）且所屬 session 未授權時，SHALL `throw` 阻止該 tool call 執行。git plumbing（如 `git commit-tree`）與 `--continue` 家族（`git rebase --continue`、`git merge --continue`、`git cherry-pick`）SHALL NOT 被阻擋。

#### Scenario: AI 執行一般 git commit 被擋

- **WHEN** 未授權 session 中 bash tool 收到 `git commit -m "x"`
- **THEN** 該 tool call SHALL 因 throw 而失敗，指令未執行

#### Scenario: git -C 變體被擋

- **WHEN** bash tool 收到 `git -C /some/path commit -m "x"`
- **THEN** 該 tool call SHALL 被阻擋

#### Scenario: chain 中的 git commit 被擋

- **WHEN** bash tool 收到 `git add . && git commit -m "x"`
- **THEN** 該 tool call SHALL 被阻擋

#### Scenario: env prefix 變體被擋

- **WHEN** bash tool 收到 `GIT_EDITOR=true git commit`
- **THEN** 該 tool call SHALL 被阻擋

#### Scenario: plumbing 指令不擋

- **WHEN** bash tool 收到 `git commit-tree <sha> -m "x"`
- **THEN** 該 tool call SHALL NOT 因 Commit Gate 被阻擋

#### Scenario: --continue 家族不擋

- **WHEN** bash tool 收到 `git rebase --continue` 或 `git merge --continue`
- **THEN** 該 tool call SHALL NOT 因 Commit Gate 被阻擋

### Requirement: 阻擋訊息引導任務繼續

阻擋時 `throw` 的錯誤訊息 SHALL 為英文，並 SHALL 包含三個要素：(1) 「user has forbidden commits this session」陳述（命中 ulw COMMIT DISCIPLINE 的 skip 條件 "Skip only when the user forbade commits this session"）；(2) 指示跳過 commit 並繼續完成當前任務、變更保持 uncommitted、使用者將經由 `/commit` 手動 commit；(3) 指示不得重試或繞路（do not retry or work around）。

#### Scenario: 錯誤訊息含必要要素

- **WHEN** 未授權 session 的 `git commit` 被阻擋
- **THEN** 錯誤訊息 SHALL 同時含 "forbidden commits this session"、"continue completing"、"/commit" 與 "Do not retry or work around" 等要素

### Requirement: authorized session 授權與放行

`command.execute.before` hook 於 `input.command`（normalize 前導 `/`）等於 `"commit"` 時 SHALL 將該 `sessionID` 標記為 authorized session。authorized session 中匹配 `git commit` 的 bash tool call SHALL 放行（Secret Guard 的 gitleaks 掃描行為不變）。非 `/commit` session（含所有 subagent 的獨立 sessionID）SHALL 不具授權。

#### Scenario: /commit 後同 session 的 commit 放行

- **WHEN** session 曾執行 `/commit`（`command.execute.before` 收到 `command: "commit"`），隨後同 session 的 bash tool 收到 `git commit -m "x"`
- **THEN** 該 tool call SHALL NOT 因 Commit Gate 被阻擋

#### Scenario: subagent 不繼承授權

- **WHEN** 主 session 已授權，另一 `sessionID`（subagent）的 bash tool 收到 `git commit -m "x"`
- **THEN** 該 tool call SHALL 被阻擋

### Requirement: 授權清除與 state 生命週期

授權 state SHALL 以 `sessionID` 為 key（`Map`），無 TTL。任何非 `/commit` 的 command 執行（`command.execute.before` 的 `command` normalize 後不等於 `"commit"`）SHALL 清除該 session 授權。`session.deleted` event SHALL 移除該 session 的 state。`session.idle` SHALL NOT 清除授權（`/commit` 多輪互動的 phase 之間會 idle，清除會擋到 Phase 4 的實際 commit）。

#### Scenario: 其他 slash command 清除授權

- **WHEN** session 已因 `/commit` 授權，隨後執行 `/eli5`（`command: "eli5"`），再收到 `git commit -m "x"`
- **THEN** 該 tool call SHALL 被阻擋

#### Scenario: session.deleted 清理 state

- **WHEN** session 已授權且收到 `session.deleted` event，再以同 sessionID 收到 `git commit -m "x"`
- **THEN** 該 tool call SHALL 被阻擋（state 已清除）

#### Scenario: 非 commit 指令不受影響

- **WHEN** 未授權 session 的 bash tool 收到 `git status` 或 `git add .`
- **THEN** 該 tool call SHALL NOT 因 Commit Gate 被阻擋
