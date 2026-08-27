# Proposal: add-opencode-secret-guard

## Why

AI agent（OpenCode）能透過 bash tool 自行執行 `git add` / `git commit` / `git push`，一旦把金鑰（`.env`、`.credentials.json`、API token）寫進 tracked file 並 commit + push，就永久進入 remote 歷史。目前 dotfiles 只有 `.gitignore` 被動遮蔽，沒有任何主動攔截機制；威脅模型設定為「防 AI 手滑」，需要在 OpenCode 層擋下洩漏路徑。

## What Changes

- `opencode/opencode.json` 新增 `permission` 區塊：
  - `permission.read`：deny `**/.env`、`**/.env.*`（allow `**/.env.example`）、`**/.credentials.json`（積極版）
  - `permission.bash`：`"git push *": "ask"` — AI 的 push 需人工確認，吃到現有 `permission.asked` → `notify-waiting.sh` bell 通知鏈
- 新增 `opencode/plugins/guard.ts`：透過 `tool.execute.before` 攔 bash tool 的 `git commit` 指令，執行 `gitleaks protect --staged --redact` 掃描 staged 內容；掃到 secret 就 `throw` 擋掉該 tool call（錯誤訊息回給 model）
- **fail-closed**：機器上沒有 `gitleaks` binary 時，guard plugin 拒絕所有 AI 的 `git commit`（錯誤訊息指示安裝方式），逼迫環境補齊工具而非靜默失去保護
- `docs/SETUP.md` 與 `README.md` 加入 `gitleaks` 為必要依賴與安裝說明
- `opencode/package.json` 無需變更（plugin 沿用既有 `@opencode-ai/plugin` SDK）

## Capabilities

### New Capabilities

- `opencode-secret-guard`: OpenCode 層的三層金鑰洩漏防護行為 — read deny 敏感檔、commit 前 staged 內容掃描（gitleaks，fail-closed）、push 前人工確認

### Modified Capabilities

- `opencode-config-files`: 檔案清單需求變更 — `opencode.json` 內容需求新增 `permission` 區塊；`plugins/` 新增 `guard.ts`；deploy symlink 機制不變（`plugins/` 已是目錄級 symlink，新檔案自動涵蓋）

## Impact

- **變更檔案**：`opencode/opencode.json`（新增 permission 區塊）、`opencode/plugins/guard.ts`（新檔）、`README.md`（結構說明 + 依賴）、`docs/SETUP.md`（gitleaks 安裝）、`CONTEXT.md`（新建：本 change 釘出的 domain terms — Secret Guard、fail-closed、staged 掃描）
- **新外部依賴**：`gitleaks`（機器級 binary，非 npm 套件）— fail-closed 設計下缺少它時 AI 的 `git commit` 全被擋
- **行為影響**：全域 config（`~/.config/opencode/`）影響所有 project — AI 在任何 repo 都讀不到 `.env` 類檔案、push 都要人工確認
- **不影響**：Claude Code 走獨立 hooks 機制，不在此 change 範圍（防護 gap 已知，留待未來 `core.hooksPath` 方案）
- **已知殘留風險**（接受）：project 層 `opencode.json` 可覆蓋 global permission；AI 用 bash `cat .env` 可繞過 read deny（bash command 內容掃描只針對 git commit，不做萬用 regex 擋截）
