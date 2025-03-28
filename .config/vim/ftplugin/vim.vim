" SPDX-License-Identifier: MIT
" Copyright (c) 2020 - 2022 Julian Prein

" Source config upon saving vim file.
" Group to avoid "exponential" reloading. See:
" https://stackoverflow.com/questions/2400264/is-it-possible-to-apply-vim-configurations-without-restarting
augroup vimrc_reload
	autocmd! BufWritePost <buffer> source $MYVIMRC | echom "Reloaded" | redraw
augroup END
