-- ============================================================================
-- Fugitive 設定 (Git 整合)
-- ============================================================================

-- Fugitive 主要透過指令使用，這裡設定快捷鍵
local map = vim.keymap.set

-- Git blame (逐行追蹤修改歷史)
map("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })

-- Git diff split (垂直分割比對差異)
map("n", "<leader>gd", "<cmd>Gvdiffsplit<cr>", { desc = "Git diff split" })
