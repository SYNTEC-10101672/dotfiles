# dotfiles

個人化開發環境設定檔，包含 Bash、Vim、Git 和 Claude Code 的配置。

## 功能特色

- 🎨 **Bash**: 自訂提示符（支援 Git 狀態顯示）、別名、環境變數
- ⚡ **Vim**: 完整的 Vim 開發環境（包含 LSP、NERDTree、CtrlP 等）
- 🔧 **Git**: 顏色配置、別名、自動 rebase
- 📊 **Tig**: Git 文字介面工具，支援美化的 commit graph 和 vim 風格操作
- 🖥️ **Tmux**: 終端機多工器，支援 Vim 風格操作和美化狀態列
- 🤖 **Claude Code**: SYNTEC 嵌入式開發模板（支援多專案類型和人設系統）

## 快速安裝

```bash
# 克隆 repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 安裝所有設定（自動備份現有檔案）
make install

# 安裝 fzf（Tig 檔案選擇器需要）
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin

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
make tig       # 安裝 Tig 設定
make tmux      # 安裝 Tmux 設定
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
├── .tigrc                # Tig 設定檔（Git 文字介面）
├── .tmux.conf            # Tmux 設定檔（終端機多工器）
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

## Tmux 設定

### 特色功能

- **Vim 風格操作**: 使用 hjkl 按鍵移動和操作面板/視窗
- **Ctrl-w 視窗切換**: 類似 Vim 的 `Ctrl-w` + `hjkl` 快速切換視窗
- **滑鼠支援**: 可使用滑鼠點擊切換視窗、調整面板大小
- **美化狀態列**: 顯示 session、時間、主機名等資訊
- **快速鍵優化**: 更直覺的面板分割和視窗切換
- **複製模式**: Vi 風格的文字選取和複製
- **自動編號**: 視窗自動重新編號，保持連續性
- **中文支援**: UTF-8 編碼，完整支援中文顯示

### 常用快捷鍵

以下快捷鍵使用 `Ctrl-b` 作為 prefix（記作 `<prefix>`）

**基本操作：**
- `<prefix> r` - 重新載入配置檔
- `<prefix> ?` - 顯示所有快捷鍵
- `<prefix> d` - 離開（detach）session

**視窗管理：**
- `<prefix> c` - 新建視窗
- `<prefix> ,` - 重新命名視窗
- `<prefix> &` - 關閉視窗
- `<prefix> a` - 切換到上一個視窗
- `Ctrl-w` + `h/l` - Vim 風格切換視窗（左/右，不需要 prefix）
- `Ctrl-w` + `j/k` - Vim 風格切換視窗（下一個/上一個）
- `Ctrl-w` + `c` - 新建視窗（在當前路徑）
- `Shift-Left` / `Shift-Right` - 切換視窗（不需要 prefix）
- `<prefix> Ctrl-h` / `<prefix> Ctrl-l` - 快速切換視窗

**面板管理：**
- `<prefix> |` - 垂直分割面板
- `<prefix> -` - 水平分割面板
- `<prefix> h/j/k/l` - Vim 風格切換面板（左/下/上/右）
- `Alt-方向鍵` - 切換面板（不需要 prefix）
- `<prefix> H/J/K/L` - 調整面板大小（可重複按）
- `<prefix> x` - 關閉面板
- `<prefix> z` - 最大化/還原當前面板

**複製模式：**
- `<prefix> Escape` - 進入複製模式
- `v` - 開始選取（在複製模式中）
- `y` - 複製選取內容（在複製模式中）
- `r` - 矩形選取模式（在複製模式中）
- `<prefix> p` - 貼上

**其他：**
- `<prefix> :` - 命令模式
- `<prefix> t` - 顯示時鐘

### 常用指令

```bash
# 啟動 tmux
tmux

# 啟動並命名 session
tmux new -s 工作

# 列出所有 session
tmux ls

# 重新連接 session
tmux attach -t 工作

# 重新連接最後的 session
tmux attach

# 刪除 session
tmux kill-session -t 工作

# 刪除所有 session
tmux kill-server
```

### 進階使用

**多個 Session 工作流程：**
```bash
# 為不同專案建立不同 session
tmux new -s dotfiles     # 開發專案
tmux new -s server       # 伺服器監控
tmux new -s debug        # 除錯工作

# 在 session 間切換
<prefix> s              # 顯示 session 列表
<prefix> (              # 切換到上一個 session
<prefix> )              # 切換到下一個 session
```

**本地自訂設定：**

如需個人專屬設定，可建立 `~/.tmux.conf.local`：
```bash
# ~/.tmux.conf.local
# 這裡的設定不會被版本控制

# 例如：使用原本的 prefix
set-option -g prefix C-b
unbind C-a
```

## Tig 設定

### 特色功能

- **美化的 commit graph**: 視覺化顯示分支和合併歷史
- **Vim 風格操作**: 使用 hjkl 和其他 vim 按鍵移動
- **Vimdiff 整合**: 按 `D` 鍵即可使用 vimdiff 查看差異（已整合 Git difftool）
- **多視圖切換**: 快速在 main、diff、log、tree、blame 等視圖間切換
- **互動式操作**: 支援 stage、unstage、commit 等 Git 操作
- **滑鼠支援**: 可使用滑鼠點擊和滾動
- **自訂快捷鍵**: 針對常用操作設定便捷按鍵

### 常用指令

```bash
# 啟動 tig (檢視所有 commit)
tig

# 檢視特定檔案的歷史
tig <檔案名稱>

# 檢視特定分支
tig <分支名稱>

# 檢視 diff
tig show <commit>

# 檢視當前變更
tig status
```

### 常用快捷鍵

在 tig 介面中：

**視圖切換：**
- `m` - main view (commit 歷史)
- `d` - diff view (差異檢視)
- `l` - log view (詳細日誌)
- `t` - tree view (檔案樹)
- `b` - blame view (逐行追蹤)
- `s` - status view (工作區狀態)

**Vim 風格移動：**
- `h` / `j` / `k` / `l` - 左/下/上/右移動
- `g` / `G` - 跳到第一行 / 最後一行
- `<Space>` - 向下翻頁
- `<Ctrl-d>` / `<Ctrl-u>` - 半頁捲動
- `<Ctrl-f>` / `<Ctrl-b>` - 整頁捲動

**互動式檔案選擇與 Vimdiff 整合：**
- `M` (main view) - 標記當前 commit
- `D` (main view) - 顯示檔案選擇器，選擇要用 vimdiff 查看的檔案
  - 沒有標記 commit：查看當前 commit 的變更
  - 有標記 commit：比對標記的 commit 與當前 commit
  - `j`/`k` - 上下移動（vim 風格）
  - `/` - 進入搜尋模式（模糊搜尋檔案）
  - `Enter` - 選擇檔案開啟 vimdiff
  - `ESC` - 退出回到 tig
- `Ctrl-M` (main view) - 顯示目前標記的 commit
- `Ctrl-X` (main view) - 清除標記的 commit
- `D` (diff view) - 使用 vimdiff 查看當前檔案差異
- `D` (log view) - 使用 vimdiff 查看 commit 差異
- `D` (status view) - 使用 vimdiff 比較工作區變更

**其他操作：**
- `q` - 退出當前視圖
- `/` - 搜尋
- `<F5>` - 重新整理
- `E` - 使用編輯器開啟檔案

### 進階功能

配置檔案支援：
- UTF-8 字元的美化 graph 顯示（可切換為 ASCII 模式）
- 自訂顏色主題
- 相對時間顯示
- 忽略空白變更
- 外部編輯器整合
- **互動式檔案選擇器**：使用 fzf 提供流暢的檔案選擇體驗
  - 支援 vim 風格的 j/k 移動
  - 模糊搜尋快速過濾檔案
  - 顯示變更統計（新增/刪除行數）

**檔案選擇器工作流程：**
1. 在 tig 中瀏覽 commit 歷史
2. 按 `M` 標記一個 commit（可選）
3. 移動到另一個 commit（或停留在同一個）
4. 按 `D` 顯示檔案列表
5. 用 `j`/`k` 或 `/` 搜尋選擇檔案
6. 按 `Enter` 開啟 vimdiff
7. 看完自動回到檔案列表，繼續選擇或按 `ESC` 退出

詳細設定請參考 `.tigrc` 和 `scripts/tig-diff-selector.sh`

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
- Tig 2.0+（可選，用於 Git 圖形介面）
- fzf（必需，用於 Tig 互動式檔案選擇器）
- Docker（若使用 Claude Code MCP 功能）

## 問題排除

### fzf 未安裝

如果在使用 tig 按 `D` 時看到 `fzf not found` 錯誤：

```bash
# 安裝 fzf 到使用者目錄
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin

# 或使用系統套件管理器（需要 sudo）
sudo apt-get install fzf  # Ubuntu/Debian
```

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
