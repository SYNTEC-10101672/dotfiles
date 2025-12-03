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

-- 自動設定開發配置檔案函式
local function setup_omnisharp_config()
  -- 尋找 appkernel32.sln 或 Appkernel32.sln
  local sln_file = vim.fn.findfile('appkernel32.sln', '.;')
  if sln_file == '' then
    sln_file = vim.fn.findfile('Appkernel32.sln', '.;')
  end

  if sln_file ~= '' then
    local sln_dir = vim.fn.fnamemodify(sln_file, ':p:h')
    local omnisharp_config = sln_dir .. '/omnisharp.json'
    local omnisharp_template = vim.fn.expand('~/.dotfiles/.appkernel/omnisharp.json')
    local editorconfig = sln_dir .. '/.editorconfig'
    local editorconfig_template = vim.fn.expand('~/.dotfiles/.appkernel/.editorconfig')

    -- 創建 omnisharp.json symlink
    if vim.fn.filereadable(omnisharp_config) == 0 and vim.fn.filereadable(omnisharp_template) == 1 then
      vim.fn.system(string.format('ln -s %s %s',
        vim.fn.shellescape(omnisharp_template),
        vim.fn.shellescape(omnisharp_config)))
      vim.api.nvim_echo({{
        'Created omnisharp.json symlink at ' .. sln_dir,
        'WarningMsg'
      }}, true, {})
    end

    -- 創建 .editorconfig symlink
    if vim.fn.filereadable(editorconfig) == 0 and vim.fn.filereadable(editorconfig_template) == 1 then
      vim.fn.system(string.format('ln -s %s %s',
        vim.fn.shellescape(editorconfig_template),
        vim.fn.shellescape(editorconfig)))
      vim.api.nvim_echo({{
        'Created .editorconfig symlink at ' .. sln_dir,
        'WarningMsg'
      }}, true, {})
    end
  end
end

-- C# 檔案類型自動命令
vim.api.nvim_create_augroup('omnisharp_commands', { clear = true })

-- 進入 C# 檔案時自動設定
vim.api.nvim_create_autocmd('BufEnter', {
  group = 'omnisharp_commands',
  pattern = '*.cs',
  callback = setup_omnisharp_config,
})

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
