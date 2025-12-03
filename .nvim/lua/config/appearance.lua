-- ============================================================================
-- 外觀設定
-- ============================================================================

-- 設定色彩主題
-- 可選：gruvbox, tokyonight, catppuccin
vim.cmd([[colorscheme gruvbox]])

-- 如果要使用其他主題，可以取消註解以下其中一行：
-- vim.cmd([[colorscheme tokyonight]])
-- vim.cmd([[colorscheme catppuccin]])

-- Gruvbox 主題設定
vim.g.gruvbox_contrast_dark = "medium"  -- soft, medium, hard
vim.g.gruvbox_contrast_light = "medium"
vim.o.background = "dark"  -- dark 或 light

-- ============================================================================
-- Lualine 設定
-- ============================================================================
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

lualine.setup({
  options = {
    icons_enabled = true,
    theme = "auto",  -- 自動配合色彩主題
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = { "dashboard", "alpha", "starter" },
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true,  -- 使用全域狀態列
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {
      {
        "filename",
        file_status = true,
        path = 1,  -- 0: 只顯示檔名, 1: 相對路徑, 2: 絕對路徑
      },
    },
    lualine_x = {
      {
        "encoding",
        show_bomb = true,
      },
      "fileformat",
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { "nvim-tree", "quickfix", "trouble" },
})
