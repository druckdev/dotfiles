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
	let $XDG_CACHE_HOME = '~/.cache'
endif
if empty($XDG_CONFIG_HOME)
	let $XDG_CONFIG_HOME = '~/.config'
endif
if empty($XDG_DATA_HOME)
	let $XDG_DATA_HOME = '~/.local/share'
endif

if !isdirectory($XDG_CACHE_HOME . "/vim/swap")
	call mkdir($XDG_CACHE_HOME . "/vim/swap", "p")
endif
set directory=$XDG_CACHE_HOME/vim/swap/

if !isdirectory($XDG_DATA_HOME . "/vim/backup")
	call mkdir($XDG_DATA_HOME . "/vim/backup", "p")
endif
set backupdir=$XDG_DATA_HOME/vim/backup/

if !isdirectory($XDG_DATA_HOME . "/vim/undo")
	call mkdir($XDG_DATA_HOME . "/vim/undo", "p")
endif
set undodir=$XDG_DATA_HOME/vim/undo/

if (!has('nvim'))
	set viminfo+=n$XDG_DATA_HOME/vim/viminfo
endif

set runtimepath-=~/.vim       runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath-=~/.vim/after runtimepath+=$XDG_CONFIG_HOME/vim/after
set packpath-=~/.vim          packpath^=$XDG_CONFIG_HOME/vim

source $XDG_CONFIG_HOME/vim/vimrc
