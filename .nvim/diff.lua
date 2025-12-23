-- ============================================================================
-- Neovim Diff Tool 精簡設定
-- 用於 git difftool，不載入 plugins 和 LSP，只保留基本功能
-- ============================================================================

local opt = vim.opt
local g = vim.g

-- ============================================================================
-- 基礎選項
-- ============================================================================

g.mapleader = ","
g.maplocalleader = ","

-- 基本設定
opt.compatible = false
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.hidden = true
opt.mouse = "a"

-- 編碼設定
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- 外觀設定
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false

-- 縮排設定
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true

-- 搜尋設定
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 分割視窗設定
opt.splitright = true
opt.splitbelow = true

-- 效能設定
opt.updatetime = 250
opt.timeoutlen = 300

-- 備份設定
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

-- 終端機真彩色支援
opt.termguicolors = true

-- 捲動設定
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 顯示不可見字元
opt.list = true
opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
}

-- ============================================================================
-- 色彩主題（不依賴 plugins）
-- ============================================================================

-- 使用內建的 gruvbox 或設定簡單的配色
pcall(function()
  vim.cmd([[colorscheme gruvbox]])
  vim.g.gruvbox_contrast_dark = "medium"
  vim.o.background = "dark"
end)

-- 如果 gruvbox 不存在，使用內建主題
if vim.g.colors_name ~= "gruvbox" then
  vim.cmd([[colorscheme desert]])
end

-- ============================================================================
-- 快捷鍵設定
-- ============================================================================

local function keymap(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.keymap.set(mode, lhs, rhs, opts)
end

local opts = { noremap = true, silent = true }

-- ESC to clear search highlight
keymap("n", "<Esc>", ":noh<CR>", opts)

-- 視窗導航
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 調整視窗大小
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Visual 模式移動文字
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- 貼上時不覆蓋暫存器
keymap("v", "p", '"_dP', opts)

-- 保持游標在中間
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
keymap("n", "J", "mzJ`z", opts)

-- 快速儲存和退出
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- 快速退出插入模式
keymap("i", "jj", "<Esc>", opts)

-- Diff 專用快捷鍵
keymap("n", "do", ":diffget<CR>", opts)      -- diff obtain
keymap("n", "dp", ":diffput<CR>", opts)      -- diff put
keymap("n", "[c", "[c", opts)                -- 上一個差異
keymap("n", "]c", "]c", opts)                -- 下一個差異
keymap("n", "<leader>dt", ":diffthis<CR>", opts)
keymap("n", "<leader>do", ":diffoff<CR>", opts)

-- ============================================================================
-- Diff 模式自動設定
-- ============================================================================

-- 進入 diff 模式時的設定
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.o.diff then
      -- 同步捲動
      opt.scrollbind = true
      opt.cursorbind = true
      -- 更好的 diff 演算法
      opt.diffopt:append("algorithm:patience")
      opt.diffopt:append("indent-heuristic")
    end
  end,
})
