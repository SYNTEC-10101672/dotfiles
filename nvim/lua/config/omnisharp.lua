-- ============================================================================
-- OmniSharp C# 開發設定
-- ============================================================================

-- OmniSharp 伺服器設定
vim.g.OmniSharp_server_path = vim.fn.expand('~/.omnisharp/omnisharp')
vim.g.OmniSharp_server_stdio = 1
vim.g.OmniSharp_timeout = 5

-- 補全設定
vim.g.omnicomplete_fetch_full_documentation = 1
vim.g.OmniSharp_want_snippet = 1

-- C# 檔案類型自動命令
vim.api.nvim_create_augroup('omnisharp_commands', { clear = true })

-- 游標停止時顯示類型資訊
vim.api.nvim_create_autocmd('CursorHold', {
  group = 'omnisharp_commands',
  pattern = '*.cs',
  command = 'OmniSharpTypeLookup',
})

-- C# 檔案快捷鍵設定
vim.api.nvim_create_autocmd('FileType', {
  group = 'omnisharp_commands',
  pattern = 'cs',
  callback = function()
    local opts = { buffer = true, silent = true, noremap = true }

    -- 跳轉相關
    vim.keymap.set('n', 'gd', '<Plug>(omnisharp_go_to_definition)', opts)
    vim.keymap.set('n', 'gr', '<Plug>(omnisharp_find_usages)', opts)
    vim.keymap.set('n', 'gi', '<Plug>(omnisharp_find_implementations)', opts)

    -- OmniSharp 功能
    vim.keymap.set('n', '<Leader>osfu', '<Plug>(omnisharp_find_usages)', opts)
    vim.keymap.set('n', '<Leader>osfi', '<Plug>(omnisharp_find_implementations)', opts)
    vim.keymap.set('n', '<Leader>ospd', '<Plug>(omnisharp_preview_definition)', opts)
    vim.keymap.set('n', '<Leader>ospi', '<Plug>(omnisharp_preview_implementations)', opts)
    vim.keymap.set('n', '<Leader>ost', '<Plug>(omnisharp_type_lookup)', opts)
    vim.keymap.set('n', '<Leader>osd', '<Plug>(omnisharp_documentation)', opts)
    vim.keymap.set('n', '<Leader>osfs', '<Plug>(omnisharp_find_symbol)', opts)
    vim.keymap.set('n', '<Leader>osfx', '<Plug>(omnisharp_fix_usings)', opts)

    -- 簽名幫助
    vim.keymap.set('n', '<C-\\>', '<Plug>(omnisharp_signature_help)', opts)
    vim.keymap.set('i', '<C-\\>', '<Plug>(omnisharp_signature_help)', opts)

    -- 導航
    vim.keymap.set('n', '[[', '<Plug>(omnisharp_navigate_up)', opts)
    vim.keymap.set('n', ']]', '<Plug>(omnisharp_navigate_down)', opts)

    -- 程式碼檢查
    vim.keymap.set('n', '<Leader>osgcc', '<Plug>(omnisharp_global_code_check)', opts)

    -- 程式碼動作
    vim.keymap.set('n', '<Leader>osca', '<Plug>(omnisharp_code_actions)', opts)
    vim.keymap.set('x', '<Leader>osca', '<Plug>(omnisharp_code_actions)', opts)
    vim.keymap.set('n', '<Leader>os.', '<Plug>(omnisharp_code_action_repeat)', opts)
    vim.keymap.set('x', '<Leader>os.', '<Plug>(omnisharp_code_action_repeat)', opts)

    -- 程式碼格式化
    vim.keymap.set('n', '<Leader>os=', '<Plug>(omnisharp_code_format)', opts)
    vim.keymap.set('n', '<Leader>f', '<Plug>(omnisharp_code_format)', opts)
    vim.keymap.set('v', '<Leader>f', '=', opts)

    -- 重新命名
    vim.keymap.set('n', '<Leader>osnm', '<Plug>(omnisharp_rename)', opts)

    -- 伺服器管理
    vim.keymap.set('n', '<Leader>osre', '<Plug>(omnisharp_restart_server)', opts)
    vim.keymap.set('n', '<Leader>osst', '<Plug>(omnisharp_start_server)', opts)
    vim.keymap.set('n', '<Leader>ossp', '<Plug>(omnisharp_stop_server)', opts)
  end,
})
