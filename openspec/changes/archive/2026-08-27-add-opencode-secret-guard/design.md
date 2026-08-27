# Design: add-opencode-secret-guard

## Context

- 威脅模型：防 AI agent（OpenCode）把金鑰 commit + push。不防蓄意繞過、不防人類手滑（人類路徑由既有 `.gitignore` 與未來 git hook 方案涵蓋）。
- OpenCode 全域 config 位於 `~/.config/opencode/`，deploy 自 dotfiles 的 `opencode/`（`make opencode` symlink）。plugin 目錄已是目錄級 symlink，新 plugin 檔案自動部署。
- 既有 plugin `opencode/plugins/notify.ts` 已使用 `tool.execute.before` hook 與 `$` shell helper，guard plugin 沿用相同模式。
- API 事實（librarian 驗證，opencode docs 2026-08-27）：
  - `tool.execute.before(input, output)`：`input` 只有 `{tool, sessionID, callID}`，bash command 在 `output.args.command`
  - 在 hook 內 `throw` 會阻止該 tool call 執行（source `packages/opencode/src/session/tools.ts` + 官方測試驗證）
  - `permission.read` 支援 path glob；`write` 歸在 `edit` permission 底下
  - `permission.bash` 為 nested object，pattern 如 `"git push *"`，last matching rule wins

```
AI 洩漏 kill chain 與攔截點

read 秘密檔         bash: git commit           bash: git push
      │                     │                        │
      ▼                     ▼                        ▼
Layer 1                Layer 2                   Layer 3
permission.read        guard.ts + gitleaks       permission.bash ask
deny .env 等           --staged --redact         人工確認 + bell 通知
```

## Goals / Non-Goals

**Goals:**

- AI 讀不到已知敏感檔（`.env`、`.credentials.json`）
- AI 的 `git commit` 在 staged 內容含已知金鑰格式時被擋，錯誤訊息不洩漏 secret 本體
- AI 的 `git push` 必經人工確認
- 缺 `gitleaks` 時防護不靜默降級（fail-closed）

**Non-Goals:**

- 不擋人類的直接 git 操作（`git commit --no-verify` 對本機制無意義，因為這不是 git hook）
- 不涵蓋 Claude Code（獨立機制，未來 `core.hooksPath` 方案）
- 不做 bash command 內容的萬用 secret regex 擋截（誤報率高、whack-a-mole）
- 不掃描既有 git 歷史（202 commits 的回溯審計是獨立工作）

## Decisions

### D1: 攔截點選 `tool.execute.before` 的 commit 前掃描，而非 write 時或 push 時

- write 時掃：AI 寫任何檔案都要掃內容，誤報多（文件裡出現 `AKIA` 字樣也中）
- push 時掃：commit 已進本地歷史，事後補救要 rewrite history
- **commit 前掃 staged**：內容進 git 物件庫的最後一刻，`gitleaks protect --staged` 正好為此場景設計
- Alternative rejected：permission rule 只比對指令字串，看不到內容，無法達成目標

### D2: 掃描引擎用 gitleaks（機器級 binary），fail-closed

- gitleaks rule set 社群維護（數百種格式：`AKIA`、`ghp_`、`sk-`、PEM private key…），勝過自寫 regex
- `--redact`：輸出遮掉 secret 本體，錯誤訊息回給 model 時不會把金鑰印進對話
- fail-closed（使用者決策）：`command -v gitleaks` 失敗時 throw 擋掉 commit，錯誤訊息給安裝指令。代價是新機器未裝時 AI 不能 commit；換取的是防護永不靜默消失
- Alternative rejected（fail-open + 提醒）：新機器體驗較佳，但使用者明確選擇 fail-closed

### D3: Layer 1 read deny 用「積極版」glob（使用者決策）

```jsonc
"read": {
  "*": "allow",
  "**/.env": "deny",
  "**/.env.*": "deny",
  "**/.env.example": "allow",
  "**/.credentials.json": "deny"
}
```

- `allow` 放最後會覆蓋 deny（last matching rule wins），`.env.example` 例外必須在 deny 之後
- 代價：其他 project 的 `.env` debug 需人工開檔。已知、接受

### D4: push 用 `ask` 而非 `deny`（使用者決策）

- 保留 AI 輔助 push 工作流，人在 loop 裡確認
- `permission.asked` event 已接入 `notify-waiting.sh` bell 通知（既有 `notify.ts`），零額外成本

### D5: guard.ts 偵測「這是 git commit 指令」的方式

- `output.args.command` 含 `git commit` 子字串即觸發掃描（`git commit -m`、`git commit --amend` 皆涵蓋）
- 不解析 shell 語法（shlex 太複雜）；子字串匹配的誤觸（如 `echo "git commit"`）只會多跑一次 gitleaks，無害

### D6: guard plugin 獨立檔案，不併入 notify.ts

- 職責分離：通知 vs 安全攔截
- 兩者都是 `Plugin` export，opencode plugin loader 掃 `plugins/` 目錄自動載入，無需註冊

### D7: guard.ts 以 env override 強制 `color.ui=off` 執行 gitleaks

實測發現（2026-08-27）：本 repo `.gitconfig` 設定 `[color] ui = always`，git pipe 輸出仍帶 ANSI 色碼，gitleaks git 模式（含 `--staged`）的 diff parser 解析不出任何內容 — **靜默掃 0 bytes、exit 0**，是 fail-closed 哲學最忌諱的靜默失效。guard.ts 執行 gitleaks 時 SHALL 設定 `GIT_CONFIG_COUNT=1`、`GIT_CONFIG_KEY_0=color.ui`、`GIT_CONFIG_VALUE_0=off`（env 層覆蓋，不修改使用者 gitconfig）。T5 驗證命令亦以此 env 前綴執行。

## Risks / Trade-offs

- [gitleaks 未安裝 → 所有 AI commit 被擋] → 錯誤訊息含安裝指令；`docs/SETUP.md` 列為必要依賴
- [使用者 gitconfig `color.ui = always` → gitleaks git 模式靜默掃 0 bytes] → guard.ts env override `color.ui=off`（D7）；T5 以相同 env 驗證
- [gitleaks 誤報（文件中的範例 token）] → 專案可加 `.gitleaksignore` allowlist（gitleaks 原生機制），不修改 guard.ts
- [project 層 `opencode.json` 可覆蓋 global permission，AI 若能寫 project config 可自我解鎖] → 接受（機率低）；未來可加 `edit` permission deny `**/opencode.json`
- [AI 用 bash `cat .env` 繞過 read deny] → 接受；讀取本身不洩漏，洩漏必經 commit/push，後兩層仍有效
- [`git add -f` 強加 .gitignore 檔案] → Layer 2 的 staged 掃描仍會攔內容
- [unborn-HEAD 首次 commit：`protect --staged` 無 diff 基準，gitleaks 非 0 exit 會以「掃描失敗（fail-closed）」擋下 initial commit] → 已知殘留風險，接受（訊息已明確分類，非誤稱 finding）；spec 未要求支援
- [`cd /x && git commit` 或 `git -C /x commit`：guard 在 process cwd（project root）掃描，非指令實際目標 repo] → 已知殘留風險（false negative 路徑），接受；D5 子字串觸發的既有限制
- [gitleaks scan 增加 commit 延遲] → staged 掃描只掃 staged diff，典型 repo 毫秒級，可忽略

## Migration Plan

1. 實作 `guard.ts` + `opencode.json` permission 區塊（dotfiles repo 內）
2. 安裝 gitleaks（`docs/SETUP.md` 指引：下載 release binary 或 `go install`）
3. `make opencode` 重新 deploy symlink，重啟 opencode session 生效
4. Rollback：`git revert` dotfiles commit + `make opencode` 即恢復原狀（symlink 機制不變）

## Open Questions

（無 — 三個關鍵決策已由使用者拍板：push=ask、gitleaks 缺失=fail-closed、read deny=積極版）
