" SPDX-License-Identifier: MIT
" Copyright (c) 2020 - 2021 Julian Prein

" Commands """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis
	\ | wincmd p | diffthis
