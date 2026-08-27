## MODIFIED Requirements

### Requirement: dotfiles 包含 opencode 設定檔
`dotfiles/opencode/` 目錄 SHALL 包含 `opencode.json`、`package.json`、`oh-my-openagent.json`、`plugins/notify.ts`、`plugins/guard.ts` 與 `scripts/notify-stop.sh`、`scripts/notify-waiting.sh`，作為 opencode 設定的唯一 source of Truth。`opencode.json` SHALL 含 plugin 宣告、experimental 設定與 `permission` 區塊（read 敏感檔 deny、`git push *` ask，詳見 `opencode-secret-guard` capability）。

#### Scenario: 檔案存在
- **WHEN** 查看 dotfiles repo 的 `opencode/` 目錄
- **THEN** SHALL 存在 `opencode.json`（含 plugin 宣告、experimental 設定與 `permission` 區塊）、`package.json`（含 plugin SDK 依賴）、`oh-my-openagent.json`（agent model 設定）
- **THEN** SHALL 存在 `plugins/notify.ts`（native 通知 plugin）、`plugins/guard.ts`（金鑰洩漏防護 plugin）與 `scripts/notify-stop.sh`、`scripts/notify-waiting.sh`（通知 scripts，一般檔案）

#### Scenario: opencode.json permission 區塊內容
- **WHEN** 查看 `opencode/opencode.json` 的 `permission` 區塊
- **THEN** SHALL 含 `permission.read`（`"**/.env": "deny"`、`"**/.env.*": "deny"`、`"**/.env.example": "allow"`、`"**/.credentials.json": "deny"`、`"*": "allow"`）與 `permission.bash`（`"git push *": "ask"`）

#### Scenario: guard.ts 部署不需修改 Makefile
- **WHEN** 執行 `make opencode`
- **THEN** `plugins/guard.ts` SHALL 透過既有 `plugins/` 目錄級 symlink 自動部署，無需新增 Makefile 規則
