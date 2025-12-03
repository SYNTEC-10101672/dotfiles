-- ============================================================================
-- SSH 剪貼簿整合 (OSC 52)
-- ============================================================================
-- 此配置讓你在 SSH 連線時也能複製到 Windows/Mac 系統剪貼簿
-- 支援 tmux 環境

-- OSC 52 剪貼簿複製函式
local function osc52_yank()
  -- 取得暫存器 "0 的內容（最近一次 yank 的內容）
  local content = vim.fn.getreg('0')

  -- Base64 編碼
  local base64_content = vim.fn.system('base64 -w0', content)
  -- 移除結尾的換行符
  base64_content = vim.fn.substitute(base64_content, '\n$', '', '')

  local osc52_sequence

  -- 檢查是否在 tmux 中
  if vim.env.TMUX ~= nil and vim.env.TMUX ~= '' then
    -- Tmux 需要 DCS wrapper 來傳遞
    osc52_sequence = string.format('\x1bPtmux;\x1b\x1b]52;c;%s\x07\x1b\\', base64_content)
  else
    -- 直接使用 OSC 52
    osc52_sequence = string.format('\x1b]52;c;%s\x07', base64_content)
  end

  -- 發送到終端機
  -- 使用 io.write 更安全地處理特殊字元
  local tty = io.open('/dev/tty', 'w')
  if tty then
    tty:write(osc52_sequence)
    tty:close()
  end
end

-- 自動在 yank 後複製到系統剪貼簿
vim.api.nvim_create_augroup('Osc52YankSuccess', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'Osc52YankSuccess',
  callback = function()
    if vim.v.event.operator == 'y' then
      osc52_yank()
    end
  end,
})

-- 手動複製快捷鍵（用於測試）
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Visual 模式：選取後按 <leader>c 複製
keymap('v', '<leader>c', 'y:lua require("config.clipboard").manual_copy()<CR>', opts)

-- Normal 模式：按 <leader>c 複製當前行
keymap('n', '<leader>c', 'yy:lua require("config.clipboard").manual_copy()<CR>', opts)

-- 匯出函式供快捷鍵使用
return {
  manual_copy = osc52_yank,
}
