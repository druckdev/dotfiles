" Shorter lines. Subject should be max 50 and body max 72
setlocal colorcolumn+=51
setlocal textwidth=72
" Spell checking always enabled
setlocal spell spelllang=en

" Disable gutentags as it seems to regenerate the entire tags file when editing
" git-commits...
let g:gutentags_enabled = 0
