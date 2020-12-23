" Plugins ######################################################################
" Load all plugins in pack/*/start
packloadall

" ARM assembly syntax highlighting
autocmd BufNewFile,BufRead *.s,*.S packadd! arm-syntax-vim | set filetype=arm
" Auto completion
" needs vim >= 8.1.1719 to support features like popup and text property.
if (has('patch-8.1.1719') || has('nvim'))
	let g:coc_global_extensions =
		\ ['coc-clangd', 'coc-sh', 'coc-python', 'coc-vimtex']
	packadd! coc.nvim
	source $XDG_CONFIG_HOME/vim/coc.nvim.vim
endif
" Fuzzy finder
packadd! fzf
packadd! fzf.vim
nmap <leader>f :Files<CR>
" LaTeX
autocmd BufNewFile,BufRead *.tex packadd! vimtex
	\ | source $XDG_CONFIG_HOME/vim/vimtex.vim
" ctags
packadd! vim-gutentags
nmap <leader>t :Tags<CR>
" Surround text with parentheses, brackets, quotes, tags, etc.
let g:surround_no_mappings = 1
packadd! vim-surround
source $XDG_CONFIG_HOME/vim/vim-surround.vim
