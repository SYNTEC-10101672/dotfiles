" ============================================
" Clipboard Integration via OSC 52
" ============================================
" This plugin enables copying from Vim to Windows clipboard
" when connected via SSH (Windows Terminal, PowerShell, etc.)
" Works both inside and outside tmux

" OSC 52 clipboard copy function
function! Osc52Yank()
  let buffer=system('base64 -w0', @0)
  let buffer=substitute(buffer, "\n$", "", "")

  " Check if we're in tmux
  if $TMUX != ''
    " Tmux requires DCS wrapper for passthrough
    let buffer='\ePtmux;\e\e]52;c;'.buffer.'\x07\e\\'
  else
    " Direct OSC 52
    let buffer='\e]52;c;'.buffer.'\x07'
  endif

  " Send to terminal
  call system('printf "'.buffer.'" > /dev/tty')
endfunction

" Auto copy to system clipboard after yank in visual mode
augroup Osc52YankSuccess
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Yank() | endif
augroup END

" Manual copy command (for testing)
vnoremap <silent> <leader>c y:call Osc52Yank()<CR>
nnoremap <silent> <leader>c yy:call Osc52Yank()<CR>
