" Plugins """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Bind own variants, see keys.vim
let g:tmux_navigator_no_mappings = 1

" Load all plugins in pack/*/start
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
	source $XDG_CONFIG_HOME/vim/coc.nvim.vim
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
	" function! s:build_location_list(lines)
	" 	call setloclist(winnr(), map(copy(a:lines), '{ "filename": v:val }'))
	" 	lopen
	" endfunction

	" let g:fzf_action = { 'ctrl-l': function('s:build_location_list') }

	" Redefine :Rg to include hidden files (except for .git)
	command! -bang -nargs=* Rg
	  \ call fzf#vim#grep(
	  \   'rg --column --line-number --no-heading --color=always --smart-case --hidden -g "!.git" -- '.shellescape(<q-args>), 1,
	  \   fzf#vim#with_preview(), <bang>0)
endif
