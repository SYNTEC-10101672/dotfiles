-- ============================================================================
-- LSP 設定
-- ============================================================================

local status_ok, mason = pcall(require, "mason")
if not status_ok then
  return
end

local status_ok3, lspconfig = pcall(require, "lspconfig")
if not status_ok3 then
  return
end

-- Mason 設定
mason.setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- 不使用 mason-lspconfig 的自動功能，直接手動設定 LSP servers
-- LSP servers 請透過 :Mason 手動安裝，或使用 :MasonInstall 命令
-- 例如：:MasonInstall lua-language-server clangd pyright typescript-language-server bash-language-server json-lsp yaml-language-server

-- LSP 快捷鍵設定
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local keymap = vim.keymap.set

  -- 跳轉相關
  keymap("n", "gD", vim.lsp.buf.declaration, opts)
  keymap("n", "gd", vim.lsp.buf.definition, opts)
  keymap("n", "gi", vim.lsp.buf.implementation, opts)
  keymap("n", "gr", vim.lsp.buf.references, opts)
  keymap("n", "K", vim.lsp.buf.hover, opts)

  -- 程式碼動作
  keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
  keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  keymap("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)

  -- 診斷相關
  keymap("n", "[d", vim.diagnostic.goto_prev, opts)
  keymap("n", "]d", vim.diagnostic.goto_next, opts)
  keymap("n", "<leader>d", vim.diagnostic.open_float, opts)
  keymap("n", "<leader>dl", vim.diagnostic.setloclist, opts)

  -- 其他功能
  keymap("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  keymap("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
end

-- LSP capabilities (整合 nvim-cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_status_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- 診斷符號設定
local signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

-- 診斷設定
vim.diagnostic.config({
  virtual_text = true,
  signs = { active = signs },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- 設定懸浮視窗邊框
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

-- 設定各個 LSP server
-- 直接設定，不使用 mason-lspconfig 的自動功能
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
          },
        },
        telemetry = { enable = false },
      },
    },
  },
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
    },
  },
  pyright = {},
  tsserver = {},  -- 改成 tsserver（原本是 ts_ls）
  bashls = {},
  jsonls = {},
  yamlls = {},
}

-- 設定所有 LSP servers
for server, config in pairs(servers) do
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

-- 下面是舊的 handlers 程式碼，保留作為備用
--[[
if status_ok2 and mason_lspconfig.setup_handlers then
  mason_lspconfig.setup_handlers({
    -- 預設處理器（適用於所有 LSP servers）
    function(server_name)
      lspconfig[server_name].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,

    -- Lua LSP 特殊設定
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end,

    -- C/C++ LSP 特殊設定（ccls 整合）
    ["clangd"] = function()
      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
      })
    end,
  })
else
  -- 舊版 mason-lspconfig 的方式
  local servers = { "lua_ls", "clangd", "pyright", "ts_ls", "bashls", "jsonls", "yamlls" }
  for _, server in ipairs(servers) do
    if server == "lua_ls" then
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
            telemetry = { enable = false },
          },
        },
      })
    elseif server == "clangd" then
      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
      })
    else
      lspconfig[server].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end
  end
end
--]]
