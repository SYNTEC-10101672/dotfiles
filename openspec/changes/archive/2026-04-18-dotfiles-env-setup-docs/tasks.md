## 1. 目錄與檔案 rename

- [x] 1.1 `git mv doc/ docs/` 將目錄重新命名
- [x] 1.2 確認 `docs/PACKAGES.md` 與 `docs/ENV_SETUP.md` 已在新路徑下

## 2. 撰寫 docs/SETUP.md

- [x] 2.1 建立 `docs/SETUP.md`，刪除 `docs/PACKAGES.md`
- [x] 2.2 撰寫 Section 1：Clone repository & `make install`
- [x] 2.3 撰寫 Section 2：系統套件（jq, tmux, tig, ripgrep, fzf, fd, curl, git, make, bash-completion, python3, sshpass）——generic 說明，不指定套件管理器
- [x] 2.4 撰寫 Section 3：nvm 安裝與 node.js 安裝（distro-agnostic install script）
- [x] 2.5 撰寫 Section 4：bun runtime 安裝
- [x] 2.6 撰寫 Section 5：neovim（若系統版本不足時的安裝方式）
- [x] 2.7 撰寫 Section 6：atuin 安裝（含 bash-preexec）
- [x] 2.8 撰寫 Section 7：opencode 安裝（`npm install -g opencode@latest`）與 `make opencode`
- [x] 2.9 撰寫 Section 8：oh-my-openagent 安裝（`bunx oh-my-opencode install`）
- [x] 2.10 撰寫 Section 9：Claude Code CLI 安裝 + 13 個 plugins 安裝指令
- [x] 2.11 撰寫 Section 10：`~/.env` 設定（cp env.example → 填入 → chmod 600，指向 ENV_SETUP.md）
- [x] 2.12 撰寫 Section 11：Optional — .NET SDK 與 OmniSharp 安裝
- [x] 2.13 撰寫 Section 12：驗證（`make check` + 套件 check script）

## 3. 清理 docs/ENV_SETUP.md

- [x] 3.1 移除 SYNTEC Confluence/JIRA MCP 段落（SYNTEC_EMAIL、SYNTEC_API_TOKEN 說明）
- [x] 3.2 移除 `start-mcp-server.sh`、`check-mcp-connection.sh` 的參考
- [x] 3.3 移除文件底部的 SYNTEC MCP 故障排除段落

## 4. 清理 env.example

- [x] 4.1 移除 `SYNTEC_EMAIL` 欄位與說明
- [x] 4.2 移除 `SYNTEC_API_TOKEN` 欄位與說明

## 5. 更新 README.md

- [x] 5.1 修正專案結構圖：`.nvim/` → `nvim/`、`.claude/` → `claude/`
- [x] 5.2 更新 `doc/PACKAGES.md` 參考連結為 `docs/SETUP.md`
- [x] 5.3 移除 README 中 `cliproxyapi/`、`openspec/` 相關描述（若有）

## 6. 更新 .claude/CLAUDE.md

- [x] 6.1 加入 `## New Machine Setup` 段落，說明新機器建置時參考 `docs/SETUP.md`
