-- ============================================================================
-- Neovim Configuration (init.lua)
-- ============================================================================

-- 基礎設定
require('config.options')
require('config.keymaps')

-- 套件管理
require('plugins')

-- 延遲載入 LSP 設定（避免啟動時的錯誤）
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- LSP 設定（延遲載入）
    require('config.lsp')
  end,
})

-- 套件設定
require('config.appearance')
require('config.completion')
require('config.telescope')
require('config.tree')
require('config.git')
require('config.treesitter')
require('config.editor')

-- 語言特定設定
require('config.omnisharp')
require('config.copilot')
