# Neovim 設定說明

## 概述

這是基於 Neovim + Lua 的現代化編輯器設定，使用 lazy.nvim 作為套件管理器。

## 檔案結構

```
.nvim/
├── init.lua                 # 主設定檔（載入所有模組）
├── lazy-lock.json          # 套件版本鎖定檔
├── lua/
│   ├── plugins.lua         # 套件清單與設定
│   └── config/
│       ├── options.lua     # Neovim 基礎選項
│       ├── keymaps.lua     # 一般快捷鍵
│       ├── lsp.lua         # LSP 設定
│       ├── completion.lua  # 自動補全設定
│       ├── telescope.lua   # 模糊搜尋工具
│       ├── tree.lua        # 檔案樹設定
│       ├── git.lua         # Git 整合
│       ├── treesitter.lua  # 語法解析器
│       ├── appearance.lua  # 外觀主題
│       ├── editor.lua      # 編輯器增強功能
│       ├── omnisharp.lua   # C# 支援
│       └── copilot.lua     # GitHub Copilot
└── README.md               # 本檔案
```

## 主要功能

### LSP (Language Server Protocol)
- **管理工具**: Mason (`:Mason`)
- **支援語言**:
  - Lua (`lua_ls`)
  - C/C++ (`clangd`)
  - Python (`pyright`)
  - TypeScript/JavaScript (`tsserver`)
  - Bash (`bashls`)
  - JSON (`jsonls`)
  - YAML (`yamlls`)
  - C# (`omnisharp`)

### 套件管理
- **管理器**: lazy.nvim
- **命令**:
  - `:Lazy` - 開啟套件管理介面
  - `:Lazy sync` - 同步套件
  - `:Lazy clean` - 清理未使用套件
  - `:Lazy update` - 更新所有套件

### 自動補全
- **引擎**: nvim-cmp
- **來源**: LSP、Buffer、Path、Snippets
- **快捷鍵** (插入模式):
  - `<C-Space>` - 觸發補全
  - `<CR>` - 確認選擇
  - `<C-n>/<C-p>` - 上下選擇

### 模糊搜尋 (Telescope)
- `<leader>ff` - 搜尋檔案
- `<leader>fg` - 搜尋文字 (grep)
- `<leader>fb` - 搜尋 Buffer
- `<leader>fh` - 搜尋說明文件

### 檔案管理
- **工具**: nvim-tree
- `<C-n>` - 切換檔案樹
- `<leader>e` - 聚焦檔案樹

### Git 整合
- **工具**: gitsigns
- `]c` / `[c` - 下一個/上一個修改區塊
- `<leader>hs` - Stage 區塊
- `<leader>hr` - Reset 區塊
- `<leader>hp` - 預覽修改
- `<leader>hb` - 顯示 Blame

## 常用快捷鍵

### Leader Key
```lua
Leader = ","
```

### 一般編輯
- `<Esc>` - 清除搜尋高亮
- `<leader>w` - 快速儲存
- `<leader>q` - 快速退出

### 視窗導航
- `<C-h/j/k/l>` - 切換視窗
- `<C-Up/Down/Left/Right>` - 調整視窗大小

### Buffer 導航
- `<S-l>` - 下一個 Buffer
- `<S-h>` - 上一個 Buffer
- `<leader>bp` - 選擇 Buffer
- `<leader>bc` - 關閉 Buffer

### LSP 功能
- `gd` - 跳轉到定義
- `gD` - 跳轉到宣告
- `gi` - 跳轉到實作
- `gr` - 查找引用
- `K` - 顯示文件
- `<leader>rn` - 重新命名
- `<leader>ca` - 程式碼動作
- `<leader>f` - 格式化程式碼
- `[d` / `]d` - 上一個/下一個診斷
- `<leader>d` - 顯示診斷浮動視窗

### 診斷工具 (Trouble)
- `<leader>xx` - 切換 Trouble
- `<leader>xw` - 工作區診斷
- `<leader>xd` - 文件診斷
- `gR` - LSP 引用

## 主題

目前安裝的主題：
- Gruvbox
- Tokyo Night
- Catppuccin

修改主題請編輯 `lua/config/appearance.lua`

## 安裝 LSP Servers

使用 Mason 安裝 LSP servers：

```vim
:Mason
```

或使用命令：
```vim
:MasonInstall lua-language-server clangd pyright typescript-language-server bash-language-server json-lsp yaml-language-server
```

## 系統需求

- Neovim >= 0.10
- Git
- Node.js (用於某些 LSP servers)
- ripgrep (用於 Telescope grep)
- fd (用於 Telescope 檔案搜尋，可選)

## 維護

### 更新套件
```vim
:Lazy update
```

### 檢查健康狀態
```vim
:checkhealth
```

### 清理未使用的套件
```vim
:Lazy clean
```

## 故障排除

### LSP 未啟動
1. 檢查 LSP server 是否已安裝：`:Mason`
2. 檢查 LSP 狀態：`:LspInfo`
3. 查看日誌：`:messages`

### 套件問題
```vim
:Lazy clean
:Lazy sync
```

### 完全重置
刪除以下目錄後重新啟動 nvim：
```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

## 自訂設定

- **基礎選項**: 修改 `lua/config/options.lua`
- **快捷鍵**: 修改 `lua/config/keymaps.lua`
- **新增套件**: 修改 `lua/plugins.lua`
- **LSP 設定**: 修改 `lua/config/lsp.lua`

## 參考資源

- [Neovim 官方文件](https://neovim.io/doc/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [Mason](https://github.com/williamboman/mason.nvim)
