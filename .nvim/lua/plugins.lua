-- ============================================================================
-- 套件管理 (lazy.nvim)
-- ============================================================================

-- 自動安裝 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 套件清單
require("lazy").setup({
  -- ============================================================================
  -- 階段 1: LSP 基礎設施
  -- ============================================================================

  -- LSP/DAP/Linter/Formatter 安裝管理器
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },

  -- LSP 設定管理
  {
    "neovim/nvim-lspconfig",
    version = "v0.1.*", -- 鎖定 v0.1.x 版本，避免 v3.0 的警告
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },

  -- 自動補全引擎
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP 補全源
      "hrsh7th/cmp-buffer",        -- Buffer 補全源
      "hrsh7th/cmp-path",          -- 路徑補全源
      "hrsh7th/cmp-cmdline",       -- 命令列補全源
      "saadparwaiz1/cmp_luasnip",  -- Snippet 補全源
      "L3MON4D3/LuaSnip",          -- Snippet 引擎
    },
  },

  -- 程式碼片段引擎
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",  -- 預設 snippets 集合
    },
  },

  -- ============================================================================
  -- 階段 2: UI 改善
  -- ============================================================================

  -- 模糊搜尋工具
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
  },

  -- 檔案樹
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  },

  -- 圖示支援
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- 狀態列
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
  },

  -- Git 整合
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- ============================================================================
  -- 階段 3: 增強套件
  -- ============================================================================

  -- 語法解析器（更好的語法高亮）
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- 快捷鍵提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  -- 註解工具
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },

  -- 自動括號配對
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- 縮排指示線
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Buffer 分頁列
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
  },

  -- 更好的診斷視窗
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
  },

  -- ============================================================================
  -- 保留的舊套件（仍然好用）
  -- ============================================================================

  -- 環繞字元操作
  { "tpope/vim-surround", event = "VeryLazy" },

  -- 增強重複命令
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- Markdown 支援
  {
    "plasticboy/vim-markdown",
    ft = "markdown",
    dependencies = { "godlygeek/tabular" },
  },

  { "godlygeek/tabular", cmd = "Tabularize" },

  -- AI 輔助
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },

  -- EditorConfig 支援
  { "editorconfig/editorconfig-vim", event = "VeryLazy" },

  -- ============================================================================
  -- 語言特定套件
  -- ============================================================================

  -- C# 支援
  {
    "OmniSharp/omnisharp-vim",
    ft = "cs",
  },

  -- ============================================================================
  -- 色彩主題（可選）
  -- ============================================================================

  -- Gruvbox 主題
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
  },
}, {
  -- lazy.nvim 設定
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
