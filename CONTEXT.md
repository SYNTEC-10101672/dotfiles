# dotfiles

個人開發環境設定檔 repo：bash/zsh/nvim/git/tmux 設定與 Claude Code、OpenCode 的 agent 配置，透過 Makefile symlink 部署到 `~/.config/` 與 `$HOME`。

## Language

### AI 金鑰防護

**Secret Guard**:
OpenCode 層的三層金鑰洩漏防護機制（read deny、commit 掃描、push 確認），實作於 `opencode/plugins/guard.ts` 與 `opencode/opencode.json` 的 `permission` 區塊。
_Avoid_: git 保護、金鑰保護單獨指稱此機制時

**fail-closed**:
`guard.ts` 在 gitleaks 缺失時拒絕所有 AI `git commit` 的行為方針 — 寧可擋掉 commit 也不讓防護靜默消失。
_Avoid_: fail-open（明確被否決的方案）

**staged 掃描**:
在 `git commit` 執行前用 `gitleaks protect --staged --redact` 掃描 staged diff 內容；`--redact` 確保錯誤訊息不含 secret 明文。
_Avoid_: 內容掃描（太泛）

### Commit 授權

**Commit Gate**:
OpenCode 層的 AI `git commit` 授權機制：偵測 `git commit`（含 `-C`、chain、env prefix 形狀），未授權 session 一律擋下並指示模型繼續任務，實作於 `opencode/plugins/commit-gate.ts`。
_Avoid_: commit guard（與 Secret Guard 混淆）

**authorized session**:
使用者執行過 `/commit` 的 session；其間 AI 的 `git commit` 放行（仍過 Secret Guard）。授權隨任何其他 slash command 執行或 session 結束失效，不繼承給 subagent。
_Avoid_: 白名單 session（誤導為持久清單）

### Skill 撰寫

**ambient 規則**:
已由 system prompt（全域 `AGENTS.md`）載入的規則；skills 與 commands 對其不做路徑引用也不重抄 — skill 需要的規則內文明示，ambient 的不需要任何 pointer。
_Avoid_: 「遵循 CLAUDE.md」（dangling pointer）、「引用全域設定」（指向永遠已載入的材料是零功 pointer）

### 部署

**deploy**:
`make <target>` 以 symlink 將 dotfiles 檔案連到 `$HOME` / `~/.config/` 對應位置的動作。
_Avoid_: install 指個別檔案複製時（本 repo 一律 symlink）
