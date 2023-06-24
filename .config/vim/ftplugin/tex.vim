" Turn on line-wrapping
setlocal wrap

" Close the quickfix window after a cursor movement
let g:vimtex_quickfix_autoclose_after_keystrokes = 1

" Put all files into tex_build/
let g:vimtex_compiler_latexmk = {
	\ 'aux_dir': 'tex_build',
	\ 'out_dir': 'tex_build',
\ }

" Use zathura for vim-like bindings and synctex support
" NOTE: Check zathurarc(5) if synctex is activated
let g:vimtex_context_pdf_viewer='zathura'
let g:vimtex_view_method='zathura'
