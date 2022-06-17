" Use 4 spaces for indentation
setlocal tabstop=4
setlocal shiftwidth=0
setlocal expandtab
" Delete all 4 spaces when pressing backspace
setlocal smarttab
" PEP-8 wants 79 as maximum line length
setlocal textwidth=79
" Lines with equal indent form a fold
setlocal foldmethod=indent
" Open all folds after they were closed automatically by foldmethod=indent
normal zR
