" Plugins """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Source all plugins in XDG_CONFIG_HOME instead of waiting for after the vimrc
" was sourced.
" NOTE: packloadall somehow breaks :Man in neovim 0.8.0
for file in split(glob($XDG_CONFIG_HOME . '/vim/pack/plugins/start/*'), '\n')
	execute 'packadd' substitute(file, '.*/', '', '')
endfor

" Auto completion
" needs vim >= 8.1.1719 to support features like popup and text property as well
" as nodejs.
if ((has('patch-8.1.1719') || has('nvim')) && executable('node'))
	let g:coc_global_extensions =
		\ ['coc-clangd', 'coc-sh', 'coc-pyright', 'coc-vimtex', 'coc-vimlsp', 'coc-json']
	packadd coc.nvim
endif

" ctags
if (executable('ctags'))
	packadd vim-gutentags
	let g:gutentags_ctags_exclude = [
		\ 'node_modules/*',
		\ '.git/*',
		\ 'build/*'
	\]
endif

if (exists("g:loaded_tmux_navigator"))
	" Disable tmux navigator when zooming the Vim pane
	let g:tmux_navigator_disable_when_zoomed = 1
endif

if (get(g:, 'loaded_fzf'))
	" Redefine :Rg to include hidden files (except for .git)
	command! -bang -nargs=* Rg
	  \ call fzf#vim#grep(
	  \   'rg --column --line-number --no-heading --color=always --smart-case --hidden -g "!.git" -- '.shellescape(<q-args>), 1,
	  \   fzf#vim#with_preview(), <bang>0)
endif
