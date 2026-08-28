# Tasks: migrate-config-to-opencode

> 通用驗證：每個 task 完成後執行對應 T*（見 `## Tests`），通過才 mark `[x]`（用 `openspec-tdd-verify` skill）。
> 順序紀律：Task 1.1 內的 git mv、Makefile 改寫、`make opencode` 必須連續完成，不得中斷（dangling symlink 窗口隔離，見 design.md D7）。

## 1. Repo 結構切換（不可分割單元）

- [x] 1.1 git mv 檔案搬遷：`git mv claude/commands opencode/commands`、`git mv claude/skills opencode/skills`、`git mv claude/CLAUDE.md opencode/AGENTS.md`、`git mv .claude/CLAUDE.md AGENTS.md`（repo root）。搬遷後 `opencode/AGENTS.md` 與全部 skills/commands 檔案內容零修改（純機械搬遷，驗證 T3）。
- [x] 1.2 刪除 claude 專屬檔案：`git rm claude/settings.json`、`git rm -r claude/scripts`（4 檔：`claude-glm`、`claude-code-statusline`、`claude-notify-stop.sh`、`claude-notify-waiting.sh`；後兩者已有 identical 副本於 `opencode/scripts/`）、`git rm .claude/settings.json`。`git rm` 後以 `rmdir claude .claude` 清除空目錄殼（若存在）。
- [x] 1.3 Makefile 改寫（單一編輯單元）：
  - 刪第 5–6 行 `CLAUDE_FILES := settings.json CLAUDE.md` 與 `CLAUDE_DIRS := commands skills scripts`
  - 刪 `claude` target 整段（原第 60–70 行，含 old-layout migration 提示）
  - `.PHONY` 行與 `install:` 依賴清單移除 `claude`
  - `opencode` target：`ln -sfn $(ROOT_DIR)/claude/commands ...` 改來源為 `$(ROOT_DIR)/opencode/commands`；新增 `@ln -sfn $(ROOT_DIR)/opencode/skills $(HOME)/.config/opencode/skills` 與 `@ln -sf $(ROOT_DIR)/opencode/AGENTS.md $(HOME)/.config/opencode/AGENTS.md`
  - `scripts` target：刪 `@ln -sf $(ROOT_DIR)/claude/scripts/claude-glm $(HOME)/bin/claude-glm` 與 `@ln -sf $(ROOT_DIR)/claude/scripts/claude-code-statusline $(HOME)/bin/claude-code-statusline` 兩行
  - `uninstall` target：刪 `~/.claude/$$item` 迴圈段（原 CLAUDE_FILES/CLAUDE_DIRS 部分）與 `~/bin/claude-glm`、`~/bin/claude-code-statusline` 兩個 symlink 移除項；新增移除 `~/.config/opencode/` 的 `commands`、`skills`、`AGENTS.md` symlink
  - `check` target：刪 `~/.claude` 檢查段；commands 檢查來源改 `$(ROOT_DIR)/opencode/commands`；新增 `~/.config/opencode/skills`、`~/.config/opencode/AGENTS.md` 檢查；`~/bin` 檢查刪 claude-glm、claude-code-statusline
  - `help` target：刪 `make claude` 說明行
- [x] 1.4 立即執行 `make opencode` 重建 `~/.config/opencode/` 下全部 symlinks（含新來源 commands、新 skills、新 AGENTS.md），消除 dangling 窗口（驗證 T1、T2、T4、T6）。

## 2. 指示檔與文件清理

- [x] 2.1 root `AGENTS.md` 內文改寫（3 處）：Individual modules 行移除 `make claude`；Architecture 段重寫 — 模組清單移除 claude、`opencode/` 描述更新為「`opencode.json`、`package.json`、`oh-my-openagent.json`、`AGENTS.md`（全域指示檔）、`commands/`、`skills/`、`plugins/`、`scripts/`，整目錄部署到 `~/.config/opencode/`」、移除「commands are shared with Claude Code via the same `claude/commands` symlink」句；New Machine Setup 段移除「Claude Code plugins」字眼。其餘段落（Session Handover、Adding a New Module）不動（驗證 T8）。
- [x] 2.2 `.gitignore` 清理：刪 `# Claude Code` 區塊整段（`.claude/*`、`!.claude/CLAUDE.md`、`!.claude/settings.json` 三行，原第 8–11 行）（驗證 T9）。
- [x] 2.3 `README.md` 更新：功能特色移除「🤖 Claude Code」項、「🖥️ opencode」項改為完整描述（AGENTS.md、skills、commands、plugins）；「詳細安裝」模組清單與指令表移除 `make claude`；專案結構樹移除 `.claude/` 與 `claude/` 兩個節點、`opencode/` 節點擴充（`AGENTS.md`、`commands/`、`skills/`）、root 加 `AGENTS.md`；刪「Claude Code 設定」整節；刪「Claude Code Statusline 未顯示…」jq troubleshooting 整節；環境需求中 `jq` 說明從「Claude Code statusline JSON 解析」改為「JSON 處理器（通知 scripts 與一般工具使用）」（驗證 T10）。
- [x] 2.4 `docs/SETUP.md` 更新：刪 §9「Claude Code CLI 與 Plugins」整節（原第 253–274 行，含 `npm install -g @anthropic-ai/claude-code` 與 4 行 `claude plugin install`），原 §10–§12 重新編號為 §9–§11；驗證段刪「確認 Claude Code plugins 是否全部安裝」區塊（原第 342–346 行附近，含 `claude plugin list`）；系統套件清單中 `jq` 說明從「Claude Code statusline 必要」改為「JSON 處理器（通知 scripts 與一般工具使用）」（原第 57 行）（驗證 T11、T12）。
- [x] 2.5 `env.example` 更新：`GLM_API_KEY` 說明從「使用方式: claude-glm 命令會自動使用此 API key」改為「使用方式: opencode（Z.AI GLM provider）使用此 API key」（原第 19 行）（驗證 T13）。

## 3. 部署切換（HARD CHECKPOINT）

- [x] 3.1 ⏸ 停下請使用者開新的 opencode session（於 dotfiles repo 目錄）驗證四項：(a) system prompt 載入 root `AGENTS.md` 與全域 `~/.config/opencode/AGENTS.md`（可由 session 內詢問 AI 確認規則存在）；(b) slash commands 可用（執行 `/commit` 或 `/opsx:explore` 的進入提示）；(c) model-invoked skills 可用（`writing-for-agents` 等）；(d) 任務完成時 tmux window bar 出現 `✓` 與 BEL 通知。全部通過才繼續；任一失敗則停止並回報（驗證 T5 部署態）。
- [x] 3.2 拔除舊部署：`rm` `~/.claude/CLAUDE.md`、`~/.claude/settings.json`、`~/.claude/commands`、`~/.claude/skills`、`~/.claude/scripts` 五條 symlinks 與 `~/bin/claude-glm`、`~/bin/claude-code-statusline` 兩條 symlinks。`~/.claude/` 其餘內容（runtime：credentials、history、transcripts 等）保留不動（驗證 T14）。

## 4. 收尾

- [x] 4.1 執行 `openspec archive migrate-config-to-opencode`（specs sync：移除 8 個 capability、新增 `project-agents-md`、改寫 18 個 capability），確認 `openspec/changes/` 無殘留 active change（驗證 T15、T16）。
- [x] 4.2 以 `/commit` 完成 commit（單一 commit 涵蓋全部 repo 變更；commit message 由 `/commit` 流程產生）（驗證 T7 — 須在 commit 後執行，rename 進入 HEAD 後 `--follow` 才能追溯）。

## Tests

- [x] T1: commands 搬遷完成且舊路徑消失
  > Command: `test -f opencode/commands/commit.md && test -d opencode/commands/opsx && test ! -e claude/commands && echo PASS`
  > Expected: 輸出 `PASS`
- [x] T2: skills 搬遷完成且舊路徑消失
  > Command: `test -f opencode/skills/domain-modeling/SKILL.md && test -f opencode/skills/openspec-propose/SKILL.md && test ! -e claude/skills && echo PASS`
  > Expected: 輸出 `PASS`
- [x] T3: 純機械搬遷 — skills 與 commands 檔案皆為 100% rename（無內容修改）
  > Command: `git diff --name-status --cached HEAD | grep -E "opencode/(skills|commands)" | grep -vc "^R100"; git diff --name-status --cached HEAD | grep "^R100" | grep -cE "opencode/(skills|commands)"`
  > Expected: 第一個輸出 `0`（該路徑所有 diff 行皆為 R100）；第二個輸出 `29`（17 skills + 12 commands 檔案）。註：不可用 pathspec 過濾（`-- opencode/skills` 會使 rename detection 失效顯示為 A）；commit 後 Final phase 以 `git diff --name-status HEAD~1 HEAD` 同形式驗證
- [x] T4: 指示檔搬遷完成、claude/ 與 .claude/ 目錄消失
  > Command: `test -f opencode/AGENTS.md && test -f AGENTS.md && test ! -e claude && test ! -e .claude && echo PASS`
  > Expected: 輸出 `PASS`
- [x] T5: 新部署 symlinks 指向正確來源
  > Command: `readlink ~/.config/opencode/commands && readlink ~/.config/opencode/skills && readlink ~/.config/opencode/AGENTS.md`
  > Expected: 三行輸出分別以 `/opencode/commands`、`/opencode/skills`、`/opencode/AGENTS.md` 結尾（絕對路徑指向本 repo）
- [x] T6: Makefile 無 claude 殘留
  > Command: `if grep -q claude Makefile; then echo FOUND; else echo CLEAN; fi`
  > Expected: 輸出 `CLEAN`
- [x] T7: git 歷史保留（rename 可追溯；須在 task 4.2 commit 後執行）
  > Command: `git log --follow --format=%cs -- opencode/commands/commit.md | tail -1`
  > Expected: `2026-02-08`（最舊 commit 日期，證明 `--follow` 跨越兩次 rename 追溯到 origin；`2026-04-17` 是無 `--follow` 的值，出現即代表 rename 追溯斷了）
- [x] T8: root AGENTS.md 無 stale claude 引用
  > Command: `if grep -nE "make claude|claude/|Claude Code" AGENTS.md; then echo FOUND; else echo CLEAN; fi`
  > Expected: 輸出 `CLEAN`
- [x] T9: .gitignore 無 Claude Code 區塊
  > Command: `if grep -q claude .gitignore; then echo FOUND; else echo CLEAN; fi`
  > Expected: 輸出 `CLEAN`
- [x] T10: README 無 claude 結構性殘留
  > Command: `if grep -nE "make claude|claude/|\.claude|Claude Code" README.md; then echo FOUND; else echo CLEAN; fi`
  > Expected: 輸出 `CLEAN`
- [x] T11: SETUP.md 無 claude 安裝步驟
  > Command: `if grep -nE "claude-code|claude plugin|make claude" docs/SETUP.md; then echo FOUND; else echo CLEAN; fi`
  > Expected: 輸出 `CLEAN`
- [x] T12: SETUP.md 章節數與編號連續（原 13 節 §0–§12，刪 §9 後 12 節）
  > Command: `grep -c "^## " docs/SETUP.md && grep "^## 9\." docs/SETUP.md`
  > Expected: 第一行輸出 `12`；第二行輸出 `## 9. ~/.env 設定`（原 §10 內容上移）
- [x] T13: env.example 無 claude-glm 引用
  > Command: `if grep -q claude-glm env.example; then echo FOUND; else echo CLEAN; fi`
  > Expected: 輸出 `CLEAN`
- [x] T14: ~/.claude/ 僅剩 runtime（五條 config symlinks 已拔）
  > Command: `for l in CLAUDE.md settings.json commands skills scripts; do test ! -e ~/.claude/$l || echo "REMAIN: $l"; done; test ! -e ~/bin/claude-glm && test ! -e ~/bin/claude-code-statusline && echo PASS`
  > Expected: 輸出 `PASS`（無 `REMAIN:` 行）
- [x] T15: 8 個死亡 capability 已從主 specs 移除
  > Command: `for s in claude-config-symlink project-claude-md claude-task-notify claude-waiting-indicator glm-quota-display glm-dynamic-model-display statusline-rate-limit tmux-window-rename; do test ! -d openspec/specs/$s || echo "REMAIN: $s"; done; echo DONE`
  > Expected: 僅輸出 `DONE`（無 `REMAIN:` 行）
- [x] T16: project-agents-md capability 已建立且收錄於主 specs
  > Command: `test -f openspec/specs/project-agents-md/spec.md && echo PASS`
  > Expected: 輸出 `PASS`
