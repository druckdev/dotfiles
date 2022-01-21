" Plugins """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load all plugins in pack/*/start
packloadall

" Auto completion
" needs vim >= 8.1.1719 to support features like popup and text property.
if (has('patch-8.1.1719') || has('nvim'))
	let g:coc_global_extensions =
		\ ['coc-clangd', 'coc-sh', 'coc-python', 'coc-vimtex']
	packadd! coc.nvim
	source $XDG_CONFIG_HOME/vim/coc.nvim.vim
endif

" ctags
if (executable('ctags'))
	packadd! vim-gutentags
	let g:gutentags_ctags_exclude = [
		\ 'node_modules/*',
		\ '.git/*',
		\ 'build/*'
	\]
endif
