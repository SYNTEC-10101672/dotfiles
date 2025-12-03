-- ============================================================================
-- Neovim 基礎選項設定
-- ============================================================================

local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = ","
g.maplocalleader = ","

-- 基本設定
opt.compatible = false
opt.clipboard = "unnamedplus"  -- 使用系統剪貼簿
opt.swapfile = false            -- 不使用 swap 檔案
opt.hidden = true               -- 允許切換 buffer 而不儲存
opt.mouse = "a"                 -- 啟用滑鼠支援
opt.bomb = false                -- 不使用 BOM

-- 編碼設定
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- 外觀設定
opt.number = true               -- 顯示行號
opt.relativenumber = false      -- 不使用相對行號（可依需求改為 true）
opt.cursorline = true           -- 高亮當前行
opt.signcolumn = "yes"          -- 總是顯示符號欄（git、診斷等）
opt.colorcolumn = ""            -- 不顯示字元標線（原本是 "80"）
opt.wrap = false                -- 不自動換行

-- 縮排設定
opt.expandtab = true            -- 使用空格代替 tab
opt.shiftwidth = 2              -- 縮排寬度
opt.tabstop = 2                 -- tab 寬度
opt.softtabstop = 2
opt.smartindent = true          -- 智能縮排
opt.autoindent = true

-- 搜尋設定
opt.ignorecase = true           -- 搜尋時忽略大小寫
opt.smartcase = true            -- 但如果包含大寫則區分大小寫
opt.hlsearch = true             -- 高亮搜尋結果
opt.incsearch = true            -- 即時搜尋

-- 分割視窗設定
opt.splitright = true           -- 垂直分割時新視窗在右側
opt.splitbelow = true           -- 水平分割時新視窗在下方

-- 效能設定
opt.updatetime = 250            -- 更快的更新時間（預設 4000ms）
opt.timeoutlen = 300            -- 快捷鍵等待時間
opt.lazyredraw = true           -- 執行巨集時不重繪

-- 補全設定
opt.completeopt = { "menu", "menuone", "noselect" }

-- 備份設定
opt.backup = false
opt.writebackup = false
opt.undofile = true             -- 啟用持久性 undo
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

-- 終端機真彩色支援
opt.termguicolors = true

-- 更好的游標形狀
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- 捲動設定
opt.scrolloff = 8               -- 游標上下保留 8 行
opt.sidescrolloff = 8           -- 游標左右保留 8 列

-- 顯示不可見字元
opt.list = true
opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
}

-- 檔案類型偵測
vim.cmd([[
  filetype on
  filetype indent on
  filetype plugin on
]])
