" SPDX-License-Identifier: MIT
" Copyright (c) 2020 - 2024 Julian Prein

" Shorter lines. Subject should be max 50 and body max 72
setlocal colorcolumn+=51
setlocal textwidth=72
" Spell checking always enabled
setlocal spell spelllang=en

" Disable gutentags as it seems to regenerate the entire tags file when editing
" git-commits...
let g:gutentags_enabled = 0

" Red highlight of overflow should come at 60 chars, not 50.
" TODO: highlight chars >50, but <60 in yellow, see
"       /usr/share/nvim/runtime/syntax/gitcommit.vim
" (see a376ff7b784c ("hooks:commit-msg: Relax subject length limit to 60"))
"let g:gitcommit_summary_length = 60

" When aborting a commit I usually use :cq which I can't when committing through
" fugitive. Abbreviate it to something that works.
cabbrev <buffer> cq %d <Bar> x
