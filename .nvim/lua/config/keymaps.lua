-- ============================================================================
-- 快捷鍵設定
-- ============================================================================

-- Neovim 0.7+ 使用 vim.keymap.set
-- Neovim 0.6 使用 vim.api.nvim_set_keymap
local function keymap(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  if vim.keymap and vim.keymap.set then
    vim.keymap.set(mode, lhs, rhs, opts)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

local opts = { noremap = true, silent = true }

-- 一般編輯快捷鍵
-- ESC to clear search highlight
keymap("n", "<Esc>", ":noh<CR>", opts)

-- 更好的視窗導航
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 調整視窗大小
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer 導航
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- 在 visual 模式下移動文字
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- 貼上時不覆蓋暫存器
keymap("v", "p", '"_dP', opts)

-- 更好的 undo 斷點
keymap("i", ",", ",<C-g>u", opts)
keymap("i", ".", ".<C-g>u", opts)
keymap("i", "!", "!<C-g>u", opts)
keymap("i", "?", "?<C-g>u", opts)

-- 保持游標在中間
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
keymap("n", "J", "mzJ`z", opts)

-- 快速儲存
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- ============================================================================
-- 個人快捷鍵偏好
-- ============================================================================

-- 停用方向鍵（強制使用 hjkl）
keymap("n", "<Up>", "<Nop>", opts)
keymap("n", "<Down>", "<Nop>", opts)
keymap("n", "<Left>", "<Nop>", opts)
keymap("n", "<Right>", "<Nop>", opts)
keymap("i", "<Up>", "<Nop>", opts)
keymap("i", "<Down>", "<Nop>", opts)
keymap("i", "<Left>", "<Nop>", opts)
keymap("i", "<Right>", "<Nop>", opts)

-- Buffer 切換（補充方式）
-- 注意：已有 <S-l> 和 <S-h>，這裡額外提供 [b 和 ]b
keymap("n", "[b", ":bprevious<CR>", opts)
keymap("n", "]b", ":bnext<CR>", opts)

-- 快速退出插入模式
keymap("i", "jj", "<Esc>", opts)
keymap("i", "11", "<Esc>", opts)
keymap("v", "11", "<Esc>", opts)

-- 套件特定快捷鍵會在各自的設定檔中定義
