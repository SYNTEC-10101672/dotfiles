-- ============================================================================
-- 編輯器增強功能設定
-- ============================================================================

-- ============================================================================
-- Which-key 設定
-- ============================================================================
local status_ok, which_key = pcall(require, "which-key")
if status_ok then
  which_key.setup({
    preset = "modern",
    win = {
      border = "rounded",
    },
  })

  -- 註冊 leader key 群組
  which_key.add({
    { "<leader>f", group = "Find (Telescope)" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>h", group = "Git Hunks" },
    { "<leader>t", group = "Toggle" },
    { "<leader>w", group = "Workspace" },
  })
end

-- ============================================================================
-- Indent-blankline 設定
-- ============================================================================
local status_ok2, ibl = pcall(require, "ibl")
if status_ok2 then
  ibl.setup({
    indent = {
      char = "│",
    },
    scope = {
      enabled = true,
      show_start = true,
      show_end = false,
    },
    exclude = {
      filetypes = {
        "help",
        "dashboard",
        "NvimTree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
    },
  })
end

-- ============================================================================
-- Bufferline 設定
-- ============================================================================
local status_ok3, bufferline = pcall(require, "bufferline")
if status_ok3 then
  bufferline.setup({
    options = {
      mode = "buffers",
      numbers = "none",
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      middle_mouse_command = nil,
      indicator = {
        icon = "▎",
        style = "icon",
      },
      buffer_close_icon = "",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 18,
      max_prefix_length = 15,
      truncate_names = true,
      tab_size = 18,
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "center",
          separator = true,
        },
      },
      color_icons = true,
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = true,
      show_tab_indicators = true,
      persist_buffer_sort = true,
      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      sort_by = "id",
    },
  })

  -- Bufferline 快捷鍵
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }
  keymap("n", "<leader>bp", ":BufferLinePick<CR>", opts)
  keymap("n", "<leader>bc", ":BufferLinePickClose<CR>", opts)
end

-- ============================================================================
-- Trouble 設定
-- ============================================================================
local status_ok4, trouble = pcall(require, "trouble")
if status_ok4 then
  trouble.setup({
    position = "bottom",
    height = 10,
    width = 50,
    icons = true,
    mode = "workspace_diagnostics",
    fold_open = "",
    fold_closed = "",
    group = true,
    padding = true,
    action_keys = {
      close = "q",
      cancel = "<esc>",
      refresh = "r",
      jump = { "<cr>", "<tab>" },
      open_split = { "<c-x>" },
      open_vsplit = { "<c-v>" },
      open_tab = { "<c-t>" },
      jump_close = { "o" },
      toggle_mode = "m",
      toggle_preview = "P",
      hover = "K",
      preview = "p",
      close_folds = { "zM", "zm" },
      open_folds = { "zR", "zr" },
      toggle_fold = { "zA", "za" },
      previous = "k",
      next = "j",
    },
    indent_lines = true,
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    auto_jump = { "lsp_definitions" },
    use_diagnostic_signs = true,
  })

  -- Trouble 快捷鍵
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }
  keymap("n", "<leader>xx", ":TroubleToggle<CR>", opts)
  keymap("n", "<leader>xw", ":TroubleToggle workspace_diagnostics<CR>", opts)
  keymap("n", "<leader>xd", ":TroubleToggle document_diagnostics<CR>", opts)
  keymap("n", "<leader>xl", ":TroubleToggle loclist<CR>", opts)
  keymap("n", "<leader>xq", ":TroubleToggle quickfix<CR>", opts)
  keymap("n", "gR", ":TroubleToggle lsp_references<CR>", opts)
end

-- ============================================================================
-- Comment.nvim 已在 plugins.lua 中設定 config = true，這裡不需要額外設定
-- ============================================================================

-- ============================================================================
-- nvim-autopairs 已在 plugins.lua 中設定 config = true，這裡不需要額外設定
-- ============================================================================
