-- ============================================================================
-- GitHub Copilot 設定
-- ============================================================================

-- 啟用 Copilot for all filetypes
vim.g.copilot_filetypes = {
  ['*'] = true,
}

-- 停用 Tab 鍵映射（避免與補全衝突）
vim.g.copilot_no_tab_map = true

-- 快捷鍵設定
local keymap = vim.keymap.set
local opts = { silent = true, script = true, expr = true, replace_keycodes = false }

-- 使用 Ctrl+J 接受建議
keymap('i', '<C-J>', 'copilot#Accept("\\<CR>")', opts)

-- 導航建議
keymap('i', '<C-N>', '<Plug>(copilot-next)', { silent = true })
keymap('i', '<C-P>', '<Plug>(copilot-previous)', { silent = true })

-- 關閉建議
keymap('i', '<C-\\>', '<Plug>(copilot-dismiss)', { silent = true })

-- 啟用/停用 Copilot
keymap('n', '<leader>ce', ':Copilot enable<CR>', { silent = true, noremap = true })
keymap('n', '<leader>cd', ':Copilot disable<CR>', { silent = true, noremap = true })
