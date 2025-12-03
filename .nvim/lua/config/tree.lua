-- ============================================================================
-- Nvim-tree 設定
-- ============================================================================

local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

-- 停用 netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nvim_tree.setup({
  disable_netrw = true,
  hijack_netrw = true,
  respect_buf_cwd = true,
  sync_root_with_cwd = true,

  view = {
    width = 30,
    side = "left",
    number = false,
    relativenumber = false,
  },

  renderer = {
    highlight_git = true,
    highlight_opened_files = "none",
    root_folder_label = ":~:s?$?/..?",
    indent_markers = {
      enable = true,
    },
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = "",
        symlink = "",
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
        folder = {
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  },

  filters = {
    dotfiles = false,
    custom = { "node_modules", ".cache", "^.git$" },
  },

  git = {
    enable = true,
    ignore = false,
  },

  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },

  update_focused_file = {
    enable = true,
    update_root = true,
  },
})

-- 快捷鍵設定
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<F2>", ":NvimTreeToggle<CR>", opts)
keymap("n", "22", ":NvimTreeToggle<CR>", opts)
keymap("n", "<leader>e", ":NvimTreeFocus<CR>", opts)
