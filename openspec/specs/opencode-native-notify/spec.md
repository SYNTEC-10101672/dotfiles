## Purpose

opencode native plugin（`plugins/notify.ts` + `scripts/notify-*.sh`）驅動的 tmux window bar 通知機制。主 session 完成時顯示綠色 `✓`，permission 詢問或問答型 tool 等待使用者回應時顯示綠色 `?`，與 Claude Code 設定（`~/.claude/`）零相依，並停用 claude-code-hooks bridge。

## Requirements

### Requirement: 主 session 完成時觸發 done 通知
opencode native plugin（`dotfiles/opencode/plugins/notify.ts`）於 `session.idle` 事件觸發時，SHALL 以 `client.session.get()` 查詢該 session；若為主 session（`parentID` 為空）且使用者不在該 tmux window（`#{window_active}` 為 `0`），SHALL 執行 `dotfiles/opencode/scripts/notify-stop.sh`（透過 symlink 部署於 `~/.config/opencode/scripts/notify-stop.sh`），將 window 的 `@claude_state` 設為 `"done"` 並發送 BEL。若使用者已在該 window，SHALL NOT 執行通知。

#### Scenario: 主 session idle 且使用者不在該 window
- **WHEN** opencode 主 session（無 `parentID`）觸發 `session.idle` 事件
- **AND** `#{window_active}` 為 `0`（使用者在其他 window）
- **THEN** plugin 執行 `notify-stop.sh`
- **THEN** window 的 `@claude_state` 設為 `"done"`，window bar 顯示綠色 `✓`，並向 pane tty 發送 BEL

#### Scenario: 主 session idle 但使用者已在該 window
- **WHEN** opencode 主 session 觸發 `session.idle` 事件
- **AND** `#{window_active}` 為 `1`
- **THEN** `notify-stop.sh` 內部邏輯跳過（不設狀態、不發 BEL）
- **THEN** window bar 不顯示額外指示符

#### Scenario: 背景 agent session idle 不觸發通知
- **WHEN** opencode 背景 agent session（`parentID` 非空，如 explore / librarian）觸發 `session.idle` 事件
- **THEN** plugin 不執行 `notify-stop.sh`
- **THEN** 不產生 bell 與狀態變更

#### Scenario: 非 tmux 環境下不執行
- **WHEN** opencode 在非 tmux 環境觸發 `session.idle`（`$TMUX` 未設定）
- **THEN** script 不輸出任何內容並正常退出，不產生錯誤

### Requirement: permission 詢問時觸發 waiting 通知
opencode native plugin 於 `permission.asked` 事件觸發時（permission dialog 出現），若使用者不在該 tmux window，SHALL 執行 `~/.config/opencode/scripts/notify-waiting.sh`，將 window 的 `@claude_state` 設為 `"waiting"` 並發送 BEL。若使用者已在該 window，SHALL NOT 執行通知。

#### Scenario: permission 詢問且使用者不在該 window
- **WHEN** opencode 觸發 `permission.asked` 事件（permission dialog 出現）
- **AND** `#{window_active}` 為 `0`
- **THEN** plugin 執行 `notify-waiting.sh`
- **THEN** window 的 `@claude_state` 設為 `"waiting"`，window bar 顯示綠色 `?`，並向 pane tty 發送 BEL

#### Scenario: permission 詢問但使用者已在該 window
- **WHEN** opencode 觸發 `permission.asked` 事件
- **AND** `#{window_active}` 為 `1`
- **THEN** `notify-waiting.sh` 內部邏輯跳過（不設狀態、不發 BEL）

### Requirement: 問答型 tool 觸發 waiting 通知
問答型 tool（`question`）呈現互動選單時不觸發 `permission.asked` 事件（實證於 opencode 1.18.22）。opencode native plugin SHALL 於 `tool.execute.before` hook 且 tool 為 `question` 時，比照 permission 詢問執行 `~/.config/opencode/scripts/notify-waiting.sh`（使用者不在該 window 時設 `@claude_state` 為 `"waiting"` 並發送 BEL）。

#### Scenario: question tool 呈現互動選單且使用者不在該 window
- **WHEN** opencode 執行 tool 為 `question` 的 `tool.execute.before` hook
- **AND** `#{window_active}` 為 `0`
- **THEN** plugin 執行 `notify-waiting.sh`
- **THEN** window 的 `@claude_state` 設為 `"waiting"`，window bar 顯示綠色 `?`

#### Scenario: 非 question tool 的 tool.execute.before 不觸發通知
- **WHEN** opencode 執行 tool 為 `bash` 等非問答型 tool 的 `tool.execute.before` hook
- **THEN** plugin 不執行任何通知 script

### Requirement: 通知 scripts 與 claude 設定零相依
`dotfiles/opencode/scripts/notify-stop.sh` 與 `notify-waiting.sh` SHALL 為獨立檔案（非 symlink 至 `claude/scripts/`），邏輯沿用既有 `claude-notify-*.sh`（僅依賴 `$TMUX` / `$TMUX_PANE` 環境變數與 tmux 指令），不讀取 stdin、不參照 `~/.claude/` 任何路徑。

#### Scenario: scripts 為獨立檔案
- **WHEN** 查看 `dotfiles/opencode/scripts/` 目錄
- **THEN** 存在 `notify-stop.sh` 與 `notify-waiting.sh` 一般檔案（非 symlink）
- **THEN** 內容不含 `~/.claude` 或 `claude/scripts` 路徑參照

### Requirement: 停用 claude-code-hooks bridge
`dotfiles/opencode/oh-my-openagent.json` 的 `claude_code` 區塊 SHALL 包含 `"hooks": false`，停用 oh-my-openagent 讀取 `~/.claude/settings.json` hooks 的 bridge 機制。

#### Scenario: 設定生效
- **WHEN** 查看 `dotfiles/opencode/oh-my-openagent.json`
- **THEN** `claude_code` 區塊包含 `"hooks": false`
- **THEN** opencode 啟動後 `~/.claude/settings.json` 的 hooks（含 atuin 記錄）不再被執行

#### Scenario: tmux 通知仍正常運作
- **WHEN** bridge 停用後主 session 完成、permission 詢問
- **THEN** `✓` / `?` 通知由 native plugin 提供，行為與 bridge 版本一致（單次 bell、無重複）
