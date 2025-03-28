" SPDX-License-Identifier: MIT
" Copyright (c) 2020 - 2023 Julian Prein

" Use 4 spaces for indentation
setlocal tabstop=4
setlocal shiftwidth=0
setlocal expandtab
" Delete all 4 spaces when pressing backspace
setlocal smarttab
" Use black's default
setlocal textwidth=88
" Lines with equal indent form a fold
setlocal foldmethod=indent
" Open all folds after they were closed automatically by foldmethod=indent
normal zR
