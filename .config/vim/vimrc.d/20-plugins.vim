" Plugins """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Trigger quick-scope highlighting only when needed.
" NOTE: Has to be defined before loading the plugin
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

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
		\ ['coc-clangd', 'coc-sh', 'coc-pyright', 'coc-vimtex', 'coc-vimlsp', 'coc-json', 'coc-go']
	let g:coc_config_home = $XDG_CONFIG_HOME .. "/vim"
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

if (get(g:, 'loaded_vimwiki'))
	" Use vertical box drawing character as table separator
	call vimwiki#vars#set_syntaxlocal('rxTableSep', '│')
endif

if exists("g:loaded_nrrw_rgn")
	" Open narrow window above or to the left of the current window (default
	" is topleft). See :h aboveleft etc.
	let g:nrrw_topbot_leftright = 'aboveleft'
endif
