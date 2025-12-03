" OmniSharp-vim configuration for C# development

" Set OmniSharp server path
let g:OmniSharp_server_path = expand('~/.omnisharp/omnisharp')

" Use stdio version (works better with Mono)
let g:OmniSharp_server_stdio = 1

" Timeout in seconds to wait for a response from the server
let g:OmniSharp_timeout = 5

" Don't autoselect first omnicomplete option, show options even if there is only
" one (so the preview documentation is accessible). Remove 'preview', 'popup'
" and 'popuphidden' if you don't want to see any documentation whatsoever.
" Note that neovim does not support `popuphidden` or `popup` yet:
" https://github.com/neovim/neovim/issues/10996
if has('patch-8.1.1880')
  set completeopt=longest,menuone,popuphidden
  set completepopup=highlight:Pmenu,border:off
else
  set completeopt=longest,menuone,preview
endif

" Highlight the completion documentation popup background/foreground the same as
" the completion menu itself, for better readability with highlighted
" documentation.
" Note: completepopup is only available in Vim 8.2+, not in Neovim
if !has('nvim') && has('patch-8.2.0')
  set completepopup=highlight:Pmenu,border:off
endif

" Fetch full documentation during omnicomplete requests.
let g:omnicomplete_fetch_full_documentation = 1

" Auto-setup development configs for appkernel projects
function! SetupOmniSharpConfig()
  " Find appkernel32.sln or Appkernel32.sln in parent directories
  let sln_file = findfile('appkernel32.sln', '.;')
  if empty(sln_file)
    let sln_file = findfile('Appkernel32.sln', '.;')
  endif

  if !empty(sln_file)
    let sln_dir = fnamemodify(sln_file, ':p:h')
    let omnisharp_config = sln_dir . '/omnisharp.json'
    let omnisharp_template = expand('~/.dotfiles/.appkernel/omnisharp.json')
    let editorconfig = sln_dir . '/.editorconfig'
    let editorconfig_template = expand('~/.dotfiles/.appkernel/.editorconfig')

    " Create omnisharp.json symlink if it doesn't exist
    if !filereadable(omnisharp_config) && filereadable(omnisharp_template)
      call system('ln -s ' . shellescape(omnisharp_template) . ' ' . shellescape(omnisharp_config))
      echohl WarningMsg
      echo 'Created omnisharp.json symlink at ' . sln_dir
      echohl None
    endif

    " Create .editorconfig symlink if it doesn't exist
    if !filereadable(editorconfig) && filereadable(editorconfig_template)
      call system('ln -s ' . shellescape(editorconfig_template) . ' ' . shellescape(editorconfig))
      echohl WarningMsg
      echo 'Created .editorconfig symlink at ' . sln_dir
      echohl None
    endif
  endif
endfunction

" Key mappings for OmniSharp (only active in C# files)
augroup omnisharp_commands
  autocmd!

  " Auto-setup omnisharp.json when entering a C# file
  autocmd BufEnter *.cs call SetupOmniSharpConfig()

  " Show type information automatically when the cursor stops moving.
  " Note that the type is echoed to the Vim command line, and will overwrite
  " any other messages in this space including e.g. ALE linting messages.
  autocmd CursorHold *.cs OmniSharpTypeLookup

  " The following commands are contextual, based on the cursor position.
  autocmd FileType cs nmap <silent> <buffer> gd <Plug>(omnisharp_go_to_definition)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfu <Plug>(omnisharp_find_usages)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfi <Plug>(omnisharp_find_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ospd <Plug>(omnisharp_preview_definition)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ospi <Plug>(omnisharp_preview_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ost <Plug>(omnisharp_type_lookup)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osd <Plug>(omnisharp_documentation)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfs <Plug>(omnisharp_find_symbol)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfx <Plug>(omnisharp_fix_usings)
  autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
  autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)

  " Navigate up and down by method/property/field
  autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
  autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)

  " Find all code errors/warnings for the current solution and populate the quickfix window
  autocmd FileType cs nmap <silent> <buffer> <Leader>osgcc <Plug>(omnisharp_global_code_check)

  " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
  autocmd FileType cs xmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)

  " Repeat the last code action performed (does not use a selector)
  autocmd FileType cs nmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
  autocmd FileType cs xmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)

  " Code formatting
  autocmd FileType cs nmap <silent> <buffer> <Leader>os= <Plug>(omnisharp_code_format)
  " Additional convenient format shortcuts
  autocmd FileType cs nmap <silent> <buffer> <Leader>f <Plug>(omnisharp_code_format)
  " For visual mode: use vim's built-in indent (respects EditorConfig)
  " Note: OmniSharp doesn't support range formatting
  autocmd FileType cs vmap <silent> <buffer> <Leader>f =

  autocmd FileType cs nmap <silent> <buffer> <Leader>osnm <Plug>(omnisharp_rename)

  autocmd FileType cs nmap <silent> <buffer> <Leader>osre <Plug>(omnisharp_restart_server)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osst <Plug>(omnisharp_start_server)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ossp <Plug>(omnisharp_stop_server)
augroup END

" Enable snippet completion
let g:OmniSharp_want_snippet = 1

" Don't show the help window during autocomplete
set completeopt-=preview
