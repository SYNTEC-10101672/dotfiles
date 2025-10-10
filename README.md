# dotfiles

個人化開發環境設定檔，包含 Bash、Vim、Git 和 Claude Code 的配置。

## 功能特色

- 🎨 **Bash**: 自訂提示符（支援 Git 狀態顯示）、別名、環境變數
- ⚡ **Vim**: 完整的 Vim 開發環境（包含 LSP、NERDTree、CtrlP 等）
- 🔧 **Git**: 顏色配置、別名、自動 rebase
- 🤖 **Claude Code**: SYNTEC 嵌入式開發模板（支援多專案類型和人設系統）

## 快速安裝

```bash
# 克隆 repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 安裝所有設定（自動備份現有檔案）
make install

# 或使用 make 查看所有可用指令
make help
```

## 詳細安裝

### 1. 克隆 Repository

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### 2. 安裝設定檔

```bash
# 完整安裝（包含自動備份）
make install

# 或分別安裝個別模組
make bashrc    # 安裝 Bash 設定
make vim       # 安裝 Vim 設定
make claude    # 安裝 Claude Code 設定
make git       # 安裝 Git 設定
```

## Makefile 指令

| 指令 | 說明 |
|------|------|
| `make install` | 安裝所有設定檔（自動備份現有檔案） |
| `make backup` | 手動備份現有設定檔 |
| `make check` | 檢查安裝狀態 |
| `make uninstall` | 移除所有符號連結 |
| `make restore BACKUP=<dir>` | 從指定備份還原 |
| `make clean` | 清除所有備份檔案 |
| `make help` | 顯示說明 |

## 專案結構

```
dotfiles/
├── .aliases              # Bash 別名
├── .bashrc               # Bash 環境設定
├── .bash_profile         # Bash 啟動設定
├── .bash_prompt          # 自訂提示符（含 Git 狀態）
├── .gitconfig            # Git 設定
├── .gitignore_global     # Git 全域忽略檔案
├── .gitignore            # 本專案忽略檔案
├── .vim/                 # Vim 設定目錄
│   ├── vimrc             # Vim 主設定檔
│   ├── plugin/           # Vim 插件設定
│   ├── colors/           # 配色方案
│   └── autoload/         # vim-plug 套件管理器
├── .claude/              # Claude Code 模板
│   ├── CLAUDE.md         # 主模板設定
│   ├── personas/         # 專業人設（5種）
│   ├── project-templates/# 專案模板
│   ├── commands/         # Slash 指令
│   └── scripts/          # MCP 伺服器管理
├── Makefile              # 安裝管理腳本
└── README.md             # 本說明文件
```

## Bash 設定

### 特色功能

- **Git 狀態顯示**: 提示符自動顯示當前分支、未提交變更
- **彩色 ls**: 根據檔案類型顯示不同顏色
- **Tab 補全**: 不區分大小寫的自動補全
- **中文支援**: 預設 UTF-8 編碼，支援 fcitx 輸入法
- **NVM 支援**: Node.js 版本管理工具自動載入

### 自訂設定

可在 `~/.bashrc.local` 加入個人專屬設定（不會被版本控制）

```bash
# ~/.bashrc.local
export MY_CUSTOM_VAR="value"
alias my_alias="command"
```

## Vim 設定

### 已安裝插件

- **vim-airline**: 美化狀態列
- **NERDTree**: 檔案瀏覽器
- **CtrlP**: 模糊檔案搜尋
- **LanguageClient-neovim**: LSP 支援（C/C++）
- **vim-gitgutter**: Git 變更顯示
- **tagbar**: 程式碼大綱瀏覽
- **vim-snipmate**: 程式碼片段
- 更多插件請參考 `.vim/vimrc`

### 首次使用

```bash
# 開啟 Vim 並安裝插件
vim
:PlugInstall
```

### 常用快捷鍵

- `,` - Leader 鍵
- `jj` / `11` - 退出插入模式（ESC 替代）
- `<F2>` / `22` - 切換 NERDTree
- 詳細快捷鍵設定請參考 `.vim/plugin/keymappings.vim`

## Claude Code 模板

### 功能

- **自動專案偵測**: 根據資料夾名稱載入對應模板
- **多重人設**: 5 種專業人設（開發、除錯、架構、審查、測試）
- **MCP 整合**: Confluence/JIRA 文件搜尋和學習

### 使用方式

模板會在進入專案目錄時自動載入。可使用 slash 指令切換人設：

```
/persona debugger    # 切換為除錯專家
/persona architect   # 切換為系統架構師
/persona reviewer    # 切換為程式碼審查員
/persona tester      # 切換為測試專家
/persona default     # 回到預設人設
```

詳細說明請參考 `.claude/README.md`

## Git 設定

### 特色功能

- **彩色輸出**: diff、status、branch 都有顏色標示
- **自動 rebase**: pull 時自動 rebase
- **Vimdiff**: 使用 Vim 作為 diff 工具
- **自動 stash**: rebase 時自動儲藏變更

### 個人化設定

請修改 `.gitconfig` 中的使用者資訊：

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 備份與還原

### 自動備份

`make install` 會自動備份現有的設定檔到：
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

### 手動備份

```bash
make backup
```

### 還原備份

```bash
# 查看可用的備份
ls -d ~/.dotfiles_backup_*

# 從指定備份還原
make restore BACKUP=~/.dotfiles_backup_20241002_123456
```

### 清除備份

```bash
make clean
```

## 解除安裝

```bash
# 移除所有符號連結
make uninstall

# 還原備份（可選）
make restore BACKUP=<備份目錄>
```

## 環境需求

- Bash 4.0+
- Vim 8.0+ 或 Neovim
- Git 2.0+
- Docker（若使用 Claude Code MCP 功能）

## 問題排除

### Bash bind 警告

如果看到 `bind: warning: line editing not enabled` 警告，這是正常的非互動式 shell 執行結果，不影響功能。

### Vim 插件安裝失敗

```bash
# 手動安裝 vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 重新安裝插件
vim +PlugInstall +qall
```

### 符號連結權限問題

確保有權限寫入 `$HOME` 目錄：
```bash
ls -la ~/ | grep -E "\.(bashrc|vimrc|gitconfig)"
```

## 貢獻

歡迎提交 Issue 和 Pull Request！

## 授權

MIT License
