-- ============================================================================
-- Telescope 設定
-- ============================================================================

local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    path_display = { "smart" },
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "target/",
      "%.lock",
    },

    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-x>"] = actions.delete_buffer,
        ["<Esc>"] = actions.close,
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
      },
    },
  },

  pickers = {
    find_files = {
      hidden = true,
      find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
    },
    live_grep = {
      additional_args = function()
        return { "--hidden", "--glob", "!.git/*" }
      end,
    },
    git_status = {
      git_icons = {
        added = "+",
        changed = "~",
        copied = ">",
        deleted = "-",
        renamed = "➡",
        unmerged = "‡",
        untracked = "?",
      },
      layout_config = {
        horizontal = {
          preview_width = 0.60,
        },
      },
    },
  },

  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

-- 載入擴充套件
pcall(telescope.load_extension, "fzf")

-- 快捷鍵設定
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 檔案搜尋
keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "FF", "<cmd>Telescope live_grep<cr>", opts)  -- 搜尋檔案內容（取代舊的 Ack）
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", opts)

-- Git 相關
keymap("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", opts)
keymap("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", opts)
keymap("n", "<leader>gs", "<cmd>Telescope git_status<cr>", opts)

-- LSP 相關
keymap("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", opts)
keymap("n", "<leader>lw", "<cmd>Telescope lsp_workspace_symbols<cr>", opts)
keymap("n", "<leader>ld", "<cmd>Telescope diagnostics<cr>", opts)
