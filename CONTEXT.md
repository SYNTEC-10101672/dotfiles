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

### 部署

**deploy**:
`make <target>` 以 symlink 將 dotfiles 檔案連到 `$HOME` / `~/.config/` 對應位置的動作。
_Avoid_: install 指個別檔案複製時（本 repo 一律 symlink）
