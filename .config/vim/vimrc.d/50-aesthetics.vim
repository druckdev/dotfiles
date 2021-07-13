" Aesthetics """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use 24-bit (true-color) mode
if (has('termguicolors'))
	set termguicolors
	" https://github.com/vim/vim/issues/993
	if (&term != 'xterm-256color')
		" set Vim-specific sequences for RGB colors
		let &t_8f = "\e[38;2;%lu;%lu;%lum"
		let &t_8b = "\e[48;2;%lu;%lu;%lum"
	endif
endif
" use onedark as theme for syntax highlighting
syntax on
colorscheme onedark

" get transparent background of the terminal back
" (at least in nvim, i can't get it to work in vanilla)
if (has('nvim'))
	highlight Normal guibg=NONE
	highlight NonText guibg=NONE
endif

if (get(g:, 'loaded_fzf'))
	" Use theme colors in fzf
	let g:fzf_colors = {
		\ 'fg':      ['fg', 'Normal'],
		\ 'bg':      ['bg', 'Normal'],
		\ 'hl':      ['fg', 'Comment'],
		\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
		\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
		\ 'hl+':     ['fg', 'Statement'],
		\ 'info':    ['fg', 'PreProc'],
		\ 'border':  ['fg', 'Ignore'],
		\ 'prompt':  ['fg', 'Conditional'],
		\ 'pointer': ['fg', 'Exception'],
		\ 'marker':  ['fg', 'Keyword'],
		\ 'spinner': ['fg', 'Label'],
		\ 'header':  ['fg', 'Comment']
	\ }
	" Use a theme for bat in the preview that somewhat resembles onedark
	let $BAT_THEME='TwoDark'
endif
