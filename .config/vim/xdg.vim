" SPDX-License-Identifier: MIT
" Copyright (c) 2020 - 2024 Julian Prein

" XDG Environment For VIM
" =======================
"
" References
" ----------
"
" - http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
" - http://tlvince.com/vim-respect-xdg
" - https://wiki.archlinux.org/index.php/XDG_Base_Directory
" - https://github.com/kaleb/vim-files/blob/23ee9d4a97d21f040c63e5c6dfdb72382fada840/xdg.vim

if empty($XDG_CACHE_HOME)
	let $XDG_CACHE_HOME = $HOME . '/.cache'
endif
if empty($XDG_CONFIG_HOME)
	let $XDG_CONFIG_HOME = $HOME . '/.config'
endif
if empty($XDG_DATA_HOME)
	let $XDG_DATA_HOME = $HOME . '/.local/share'
endif

" NOTE: Double trailing slash tells vim to use the full path for swap files to
" prevent name clashings. See `:help directory`
if !isdirectory($XDG_CACHE_HOME . "/vim/swap")
	call mkdir($XDG_CACHE_HOME . "/vim/swap", "p")
endif
set directory=$XDG_CACHE_HOME/vim/swap//

if !isdirectory($XDG_DATA_HOME . "/vim/backup")
	call mkdir($XDG_DATA_HOME . "/vim/backup", "p")
endif
set backupdir=$XDG_DATA_HOME/vim/backup//

if !isdirectory($XDG_DATA_HOME . "/vim/undo")
	call mkdir($XDG_DATA_HOME . "/vim/undo", "p")
endif
set undodir=$XDG_DATA_HOME/vim/undo//

if (!has('nvim'))
	set viminfo+=n$XDG_DATA_HOME/vim/viminfo
endif

if !isdirectory($XDG_DATA_HOME . '/vim/spell')
	call mkdir($XDG_DATA_HOME . '/vim/spell', 'p')
endif
let &spellfile = $XDG_DATA_HOME . '/vim/spell/' . &spelllang . '.utf-8.add'
augroup xdg_spellfile
	au!
	" TODO: This throws `E523: not allowed here` on `:e` as the modeline is
	"       reread. Suppress or better check for sandbox/modeline before
	"       executing
	au OptionSet spelllang let &spellfile =
				\ $XDG_DATA_HOME . '/vim/spell/' . v:option_new . '.utf-8.add'
	" NOTE: Changing &spellfile is not allowed from a modeline, so we need to
	"       update it manually after the modeline was read
	au BufWinEnter * let &spellfile =
				\ $XDG_DATA_HOME . '/vim/spell/' . &spelllang . '.utf-8.add'
augroup end

set runtimepath-=~/.vim       runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath-=~/.vim/after runtimepath+=$XDG_CONFIG_HOME/vim/after
set packpath-=~/.vim          packpath^=$XDG_CONFIG_HOME/vim

" Source everything in vimrc.d/
for file in split(glob($XDG_CONFIG_HOME . '/vim/vimrc.d/**/*.vim'), '\n')
	execute 'source' file
endfor
