" GitHub Copilot Settings
" =======================

" Key Mappings
" ------------
" Accept suggestion with Ctrl+J
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" Navigate between suggestions
imap <C-N> <Plug>(copilot-next)
imap <C-P> <Plug>(copilot-previous)

" Dismiss suggestion
imap <C-\> <Plug>(copilot-dismiss)

" Toggle Copilot
nmap <leader>ce :Copilot enable<CR>
nmap <leader>cd :Copilot disable<CR>

" Additional Settings
" -------------------
" Enable Copilot for all filetypes
let g:copilot_filetypes = {
  \ '*': v:true,
  \ }
