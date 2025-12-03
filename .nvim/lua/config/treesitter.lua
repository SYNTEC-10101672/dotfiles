-- ============================================================================
-- Treesitter 設定
-- ============================================================================

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup({
  -- 自動安裝的語言解析器
  ensure_installed = {
    "c",
    "cpp",
    "c_sharp",
    "lua",
    "vim",
    "vimdoc",
    "python",
    "javascript",
    "typescript",
    "bash",
    "json",
    "yaml",
    "markdown",
    "markdown_inline",
    "html",
    "css",
  },

  -- 同步安裝語言解析器（僅適用於 `ensure_installed`）
  sync_install = false,

  -- 自動安裝缺少的解析器
  auto_install = true,

  -- 忽略的語言解析器
  ignore_install = {},

  -- 語法高亮
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },

  -- 縮排
  indent = {
    enable = true,
    disable = { "yaml", "python" },  -- 某些語言的縮排可能有問題
  },

  -- 增量選擇
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<S-CR>",
      node_decremental = "<BS>",
    },
  },

  -- 文字物件
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
})

-- 啟用 Treesitter 的 folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false  -- 預設不折疊
