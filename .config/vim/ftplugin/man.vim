setlocal nospell

" man(1) will assume it can use the full width of the terminal when
" hard-wrapping the lines. When signcolumn is enabled the width is one cell
" smaller and thus, lines that have a character in the last column will be
" wrapped by vim (i.e. almost all of them).
setlocal signcolumn=no
