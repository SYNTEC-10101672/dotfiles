# Tasks: add-opencode-secret-guard

## 1. Environment（gitleaks 先行，fail-closed 依賴它）

- [x] 1.1 安裝 gitleaks binary 到機器（`docs/SETUP.md` 將記載的方式：從 github.com/gitleaks/gitleaks releases 下載對應平台 binary 放進 `~/.local/bin`，或 `go install github.com/gitleaks/gitleaks/v8@latest`），驗證 `command -v gitleaks` 輸出路徑
- [x] 1.2 在 `/tmp/opencode` 建立 throwaway git repo（需先有 base commit——unborn HEAD 時 `protect --staged` 無 diff 基準），stage 含 fake AWS key（`AKIAQWZ7JZK4MPL3XRB2`，完整 20 字元且後 16 碼只用 `[A-Z2-7]` — gitleaks 8.30 的 aws rule charset 不含 0/1/8/9，同時避開 example key allowlist）的檔案，執行 `gitleaks protect --staged --redact`（須加 `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=color.ui GIT_CONFIG_VALUE_0=off` env override——本機 `.gitconfig` 的 `color.ui = always` 會讓 gitleaks git 模式靜默掃 0 bytes，見 design.md D7）確認 exit code 1 且輸出不含 key 明文；換乾淨檔案重跑確認 exit code 0（即 T5/T6）

## 2. Config（Layer 1 + Layer 3）

- [x] 2.1 在 `opencode/opencode.json` 新增 `permission` 區塊：`permission.read` 為 `"*": "allow"`、`"**/.env": "deny"`、`"**/.env.*": "deny"`、`"**/.credentials.json": "deny"`、`"**/.env.example": "allow"`（allow 放最後，last-matching-rule-wins）；`permission.bash` 為 `"git push *": "ask"`。既有 `plugin` 與 `experimental` 區塊不動

## 3. Plugin（Layer 2）

- [x] 3.1 建立 `opencode/plugins/guard.ts`：export `GuardPlugin: Plugin`，結構沿用 `opencode/plugins/notify.ts`（`declare const process` workaround、`$` shell helper）。`tool.execute.before` 內：`input.tool !== "bash"` 或 `output.args.command` 不含 `git commit` 子字串 → return 放行；含 → 先 `gitleaks version` 檢查（opencode plugin 的 `$` 跑在 bun shell，無 `command` builtin——`command -v gitleaks` 恆失敗會造成永久 fail-closed），缺失則 `throw`（訊息含安裝指引，fail-closed）；存在則跑 `gitleaks protect --staged --redact`（以 `$` 在 process cwd 執行，opencode 由 project root 啟動，staged 即該 repo；**必須帶 `GIT_CONFIG_COUNT=1`、`GIT_CONFIG_KEY_0=color.ui`、`GIT_CONFIG_VALUE_0=off` env**——否則 `color.ui = always` 的機器上 gitleaks 靜默掃 0 bytes，見 design.md D7），exit code 非 0 則 `throw`（訊息含 redacted 輸出，不含 secret 明文）
- [x] 3.2 E2E 驗證：在 throwaway repo（staged 含 fake AWS key）開 opencode session，要求 AI 執行 `git commit`，確認 tool call 被 throw 阻止、錯誤訊息含 gitleaks finding 且無 secret 明文；清空 staging 換乾淨檔案重試，確認 commit 成功

## 4. Docs & Deploy

- [x] 4.1 `README.md`：專案結構的 `opencode/` 說明加入 `plugins/guard.ts`（金鑰洩漏防護）；環境需求清單加入 `gitleaks`
- [x] 4.2 `docs/SETUP.md`：新機器建置流程加入 gitleaks 安裝步驟（標註 fail-closed：未安裝則 AI 的 `git commit` 全被擋）
- [x] 4.3 執行 `make opencode` 重新 deploy（`plugins/` 目錄級 symlink 自動涵蓋 `guard.ts`，無需改 Makefile），確認 `~/.config/opencode/plugins/guard.ts` 經 symlink 指向 dotfiles，重啟 opencode session 生效

## Tests

- [x] T1: read deny 設定存在
  > Command: `jq -r '.permission.read["**/.env"]' opencode/opencode.json`
  > Expected: `deny`
- [x] T2: push ask 設定存在
  > Command: `jq -r '.permission.bash["git push *"]' opencode/opencode.json`
  > Expected: `ask`
- [x] T3: guard plugin 攔截點存在
  > Command: `grep -c 'tool.execute.before' opencode/plugins/guard.ts`
  > Expected: `1`（以上）
- [x] T4: gitleaks 已安裝
  > Command: `command -v gitleaks`
  > Expected: 輸出 binary 路徑（exit 0）
- [x] T5: staged 含 secret 時 gitleaks 擋下
  > Command: `mkdir -p /tmp/opencode/sg-test && cd /tmp/opencode/sg-test && rm -rf .git config.ini clean.ini && git init -q && printf 'init\n' > README && git add README && git -c user.name=sg -c user.email=sg@test commit -qm init && printf 'aws_access_key_id = AKIAQWZ7JZK4MPL3XRB2\n' > config.ini && git add config.ini && GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=color.ui GIT_CONFIG_VALUE_0=off gitleaks git --staged --redact --no-banner --exit-code 1; echo "exit=$?"`
  > Expected: 輸出含 finding（...REDACTED...）且 `exit=1`，且輸出不含 `AKIAQWZ7JZK4MPL3XRB2` 明文
- [x] T6: staged 乾淨時 gitleaks 放行
  > Command: `cd /tmp/opencode/sg-test && git reset -q && rm -f config.ini && printf 'just a normal config\n' > clean.ini && git add clean.ini && GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=color.ui GIT_CONFIG_VALUE_0=off gitleaks git --staged --redact --no-banner --exit-code 1; echo "exit=$?"`
  > Expected: `exit=0` 且無 finding
- [x] T7: guard.ts fail-closed 分支存在
  > Command: `grep -c 'gitleaks version' opencode/plugins/guard.ts`
  > Expected: `1`（以上）
- [x] T8: plugins symlink 部署涵蓋 guard.ts
  > Command: `make opencode >/dev/null && readlink ~/.config/opencode/plugins && ls -L ~/.config/opencode/plugins/`
  > Expected: readlink 指向 `dotfiles/opencode/plugins`，ls 列出 `guard.ts` 與 `notify.ts`

**手動驗證（無法純 command 自動化）**：task 3.2 的 E2E（AI session 內 commit 被擋）與 `git push` 的 permission.asked UI + bell 通知，需人工在 opencode session 觀察。
