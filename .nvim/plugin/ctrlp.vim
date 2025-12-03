" 預設使用 MRU 模式
let g:ctrlp_cmd = 'CtrlPMRU'

" MRU 優先顯示當前工作目錄的檔案
let g:ctrlp_mruf_relative = 1

" 限制 MRU 顯示的檔案數量（可選）
let g:ctrlp_mruf_max = 250

" 設定 CtrlP 視窗顯示的最大行數
let g:ctrlp_max_height = 20

let g:ctrlp_by_filename = 1
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$|tmp$|node_modules$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }

" 啟用快取以加速搜尋
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'

" 限制搜尋結果數量
let g:ctrlp_max_files = 10000

" 使用 Silver Searcher 加速檔案搜尋
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden --ignore .git -g ""'
endif

