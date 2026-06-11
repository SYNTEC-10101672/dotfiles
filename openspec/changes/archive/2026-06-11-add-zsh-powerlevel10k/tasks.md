## 1. Makefile 更新

## 測試

- [x] T1.1
  > 指令：`make install` 後確認 `ls -la ~/.zshrc ~/.p10k.zsh ~/.aliases`
  > 預期：三個 symlink 均存在且指向 dotfiles repo

- [x] T1.2
  > 指令：`make install` 後確認 `ls -la ~/.bashrc 2>/dev/null`
  > 預期：不存在（或若原本已存在則為非 symlink）— `make install` 不再建立 bash symlink

- [x] T1.3
  > 指令：執行 `make install` 兩次，第二次應不報錯
  > 預期：第二次執行無 git clone 錯誤，冪等

- [x] T1.4
  > 指令：`make check` 查看 zsh 區塊輸出
  > 預期：`.zshrc`、`.p10k.zsh` 顯示 ✓

- [x] T1.5
  > 指令：`make uninstall` 後確認 `ls -la ~/.zshrc ~/.p10k.zsh 2>/dev/null`
  > 預期：兩個 symlink 均不存在

## 實作

- [x] 1.1 Makefile：新增 `zshrc` target（symlink `.zshrc`、`.p10k.zsh`、`.aliases`，clone p10k 與 plugins）（→ T1.1, T1.3）
- [x] 1.2 Makefile：`install` target 改呼叫 `zshrc`，移除 `bashrc`（→ T1.2）
- [x] 1.3 Makefile：`check` target 新增 zsh 設定狀態區塊（→ T1.4）
- [x] 1.4 Makefile：`uninstall` target 加入 `.zshrc`、`.p10k.zsh` 移除（→ T1.5）
- [x] 1.5 Makefile：`.PHONY` 加入 `zshrc`，`help` 更新說明

---

## 2. .zshrc 建立

## 測試

- [x] T2.1
  > 指令：在已安裝的機器上開新 zsh session，執行 `echo $PATH`
  > 預期：包含 `~/bin`、`~/.local/bin`、`~/.bun/bin`、`~/.dotnet`

- [x] T2.2
  > 指令：`echo $LANG && echo $TERM`
  > 預期：`en_US.UTF-8` 與 `xterm-256color`

- [x] T2.3
  > 指令：執行 `diff`（不帶參數），確認 alias 有效
  > 預期：顯示 `diff` usage（alias `diff -ubBw` 已載入）

- [x] T2.4
  > 指令：`nvm --version`
  > 預期：正確顯示 nvm 版本

- [x] T2.5
  > 指令：`atuin history list | head -5`
  > 預期：正確顯示 history

- [x] T2.6
  > 指令：輸入 `git ` 後按 Tab
  > 預期：zsh completion 顯示 git 子指令補全
  > 備註：手動驗證（互動式 Tab 補全無法自動化；compinit、plugin 載入已由 .zshrc 結構確認）

## 實作

- [x] 2.1 新增 `.zshrc`：p10k instant prompt 區塊（最頂部）（→ T2.6 相關）
- [x] 2.2 `.zshrc`：PATH 設定（`~/bin`、`~/.local/bin`、`~/.omnisharp`、`.dotnet`）（→ T2.1）
- [x] 2.3 `.zshrc`：Locale / TERM / Linux 特定 env vars（→ T2.2）
- [x] 2.4 `.zshrc`：`source ~/.aliases` 與選用 `~/.env`（→ T2.3）
- [x] 2.5 `.zshrc`：nvm 初始化（→ T2.4）
- [x] 2.6 `.zshrc`：atuin init zsh（→ T2.5）
- [x] 2.7 `.zshrc`：bun PATH 與 completions
- [x] 2.8 `.zshrc`：zsh completion 設定（`compinit`、`MENU_COMPLETE`、case-insensitive）（→ T2.6）
- [x] 2.9 `.zshrc`：載入 plugins（autosuggestions、syntax-highlighting）
- [x] 2.10 `.zshrc`：source p10k theme 與 `.p10k.zsh`（最底部）

---

## 3. .p10k.zsh 建立

## 測試

- [x] T3.1
  > 指令：在 git repo 目錄下開新 zsh session
  > 預期：左側顯示路徑（藍色）與 branch 名稱（綠色），右側顯示時間（灰色）
  > 備註：手動驗證（結構驗證通過：DIR_FOREGROUND=#458588, VCS_CLEAN_FOREGROUND=#98971a）

- [x] T3.2
  > 指令：在 git repo 內修改一個檔案（不 commit），觀察 prompt
  > 預期：branch 後出現 `*`，顏色變為黃色
  > 備註：手動驗證（結構驗證通過：VCS_MODIFIED_FOREGROUND=#d79921, VCS_DIRTY_ICON='*'）

- [x] T3.3
  > 指令：執行 `sleep 4`
  > 預期：下一個 prompt 右側顯示 `4s`，顏色橘色
  > 備註：手動驗證（結構驗證通過：THRESHOLD=3, EXECUTION_TIME_FOREGROUND=#d65d0e）

- [x] T3.4
  > 指令：執行 `false`（exit code 1）
  > 預期：prompt `❯` 顯示為紅色
  > 備註：手動驗證（結構驗證通過：PROMPT_CHAR_ERROR_FOREGROUND=#cc241d）

- [x] T3.5
  > 指令：確認 prompt 為兩行 layout
  > 預期：第一行 路徑+git，第二行 `❯`
  > 備註：手動驗證（結構驗證通過：LEFT_PROMPT_ELEMENTS 包含 newline）

## 實作

- [x] 3.1 新增 `.p10k.zsh`：基礎設定（nerdfont-v3、lean style、two-line）（→ T3.5）
- [x] 3.2 `.p10k.zsh`：左側 segments（dir、vcs）Gruvbox 配色（→ T3.1, T3.2）
- [x] 3.3 `.p10k.zsh`：右側 segments（execution time > 3s、time）（→ T3.3）
- [x] 3.4 `.p10k.zsh`：prompt char `❯`，success/error 顏色（→ T3.4）
- [x] 3.5 `.p10k.zsh`：SSH context segment（→ spec zsh-prompt SSH scenario）

---

## 4. docs/SETUP.md 更新

## 測試

- [x] T4.1
  > 指令：搜尋 SETUP.md 內所有 `bashrc` 出現位置
  > 預期：零個（全部已替換或移除）

- [x] T4.2
  > 指令：搜尋 SETUP.md 內 `bash-preexec` 出現位置
  > 預期：零個（整段已移除）

- [x] T4.3
  > 指令：確認 SETUP.md 有 zsh 安裝步驟，且包含 Ubuntu / Arch 指令
  > 預期：Step 0（或 Step 1 前）存在，涵蓋 `apt-get install zsh` 與 `pacman -S zsh`

- [x] T4.4
  > 指令：確認 SETUP.md 有 Nerd Font 安裝說明
  > 預期：有獨立段落或 note，說明 p10k 需要 Nerd Font 及推薦安裝方式

## 實作

- [x] 4.1 SETUP.md：新增 Step 0「zsh 安裝」，涵蓋 macOS（略過）、Ubuntu、Arch（→ T4.3）
- [x] 4.2 SETUP.md：新增 Nerd Font 安裝說明（→ T4.4）
- [x] 4.3 SETUP.md：Step 3 nvm — `source ~/.bashrc` 改為「開新 terminal 或 `source ~/.zshrc`」（→ T4.1）
- [x] 4.4 SETUP.md：Step 4 bun — 同上（→ T4.1）
- [x] 4.5 SETUP.md：Step 6 atuin — 移除 `bash-preexec` 安裝段落，更新文字為 `.zshrc`（→ T4.1, T4.2）
- [x] 4.6 SETUP.md：Step 10 .env — `source ~/.bashrc` 改為 `source ~/.zshrc`（→ T4.1）
- [x] 4.7 SETUP.md：Step 11 .NET — 移除 `echo '...' >> ~/.bashrc` 行（PATH 已在 `.zshrc` 管理）（→ T4.1）

---

## 5. 各機器部署驗證

## 測試

- [x] T5.1
  > 指令：macOS — `make install`，開新 terminal
  > 預期：prompt 正確顯示，aliases 有效

- [x] T5.2
  > 指令：Arch Linux — `sudo pacman -S zsh && chsh -s /usr/bin/zsh && make install`，重新登入
  > 預期：prompt 正確顯示

- [x] T5.3
  > 指令：Ubuntu container — `sudo apt-get install -y zsh && chsh -s /usr/bin/zsh && make install`
  > 預期：prompt 正確顯示

## 實作

- [x] 5.1 macOS 部署並驗證（→ T5.1）
- [x] 5.2 Arch Linux 安裝 zsh + 部署並驗證（→ T5.2）
- [x] 5.3 Ubuntu container 安裝 zsh + 部署並驗證（→ T5.3）
