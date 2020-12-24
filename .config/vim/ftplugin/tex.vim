let g:tex_flavor = "latex"
let g:vimtex_compiler_progname = 'nvr'

" Setup latexmk and make callback possible with synctex
" (Click into PDF to land in code)
let g:vimtex_compiler_latexmk = {
\	'build_dir' : 'build',
\	'callback' : 1,
\	'continuous' : 1,
\	'executable' : 'latexmk',
\	'hooks' : [],
\	'options' : [
\		'-verbose',
\		'-file-line-error',
\		'-synctex=1',
\		'-interaction=nonstopmode',
\		'-shell-escape',
\	],
\}

" synctex needs to be activated in zathurarc as well
let g:vimtex_context_pdf_viewer='zathura'
let g:vimtex_view_general_viewer = 'zathura'
let g:vimtex_view_method='zathura'
