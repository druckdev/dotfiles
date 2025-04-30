" Settings """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" linenumbers
set number
" If relative linenumbers are activated, have them only in the focused window
function! Numbertoggle()
	augroup numbertoggle
		au!
		au OptionSet relativenumber call Numbertoggle()

		if &relativenumber
			au BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
			au BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
		endif
	augroup END
endfunction
call Numbertoggle()

" no timeout when exiting insert-mode
" (see https://www.johnhawthorn.com/2012/09/vi-escape-delays/)
set timeoutlen=1000 ttimeoutlen=0
" smart case insensitive search (insens: /copy /Copy\c; sens: /Copy /copy\C)
set ignorecase smartcase
" Tab size
set tabstop=8
" Shift the same amount as tabstop
set shiftwidth=0
" Control how vim formats paragraphs. See :h fo-table
set formatoptions=tcro/qlnj
" Autoindent new lines
set autoindent
" Copy structure of the existing lines indent when autoindenting a new line
set copyindent
" Enables C program indenting
set cindent
" Preserve as much of the indentation as possible when changing it
set preserveindent
" Keep lines under 80 characters.
set textwidth=80
" Do not insert two spaces before a new sentence when formatting
set nojoinspaces
" see :help persistent-undo
set undofile
" Update every 300ms for better experience with plugins like gitgutter and coc
set updatetime=300
" Check for spelling in comments and strings
set spell spelllang=en
" Show the effect of a command while typing (substitute). Show partial
" off-screen results in a preview window.
if (has('nvim'))
	set inccommand=split
endif
" Put new window below/right of current
set splitbelow splitright
" What is ce there for? cw should include whitespace like dw.
if (has('nvim'))
	set cpoptions-=_
else
	nmap cw dwi
	nmap cW dWi
endif
" Highlight current line
set cursorline
" Show ruler at column behind &textwidth
set colorcolumn=+1
" Show menu for possible matches when using command-line completing.
if (has('wildmenu'))
	set wildmenu
endif
" Command-line completion tab behavior:
" First:  Complete longest common string and show wildmenu
" Second: Complete each full match (Cycle through the menu)
set wildmode=longest:full,full
" Show typed (partial) command on screen.
if (has('cmdline_info'))
	set showcmd
endif
" Show whitespace characters
set list
" Display tabs and trailing space characters as well an indicator for long lines
" when not wrapping
set listchars=tab:>·,trail:•,extends:>
" Wrap lines
set wrap
" Keep current line away from top/bottom borders of the buffer when scrolling
set scrolloff=5
" Enable mouse
set mouse=a
" Disable pesky swap file warnings
set shortmess+=A
" Automatically update file that was modified outside of vim.
" Beware that this updates only on certain events and thus works different then
" probably expected. See corresponding autocommand or:
" https://vi.stackexchange.com/questions/2702
set autoread
" Include `-` in keyword characters
set iskeyword+=-
" Do not automatically insert <EOL> at EOF if missing
set nofixendofline
" Let the cursor move beyond the EOL when in visual-block mode.
set virtualedit+=block
" Do not redraw screen while executing macros, registers and other commands that
" have not been typed.
set lazyredraw
" Visual selection does not include the line break
set selection=old
" Only one global status line
set laststatus=3
" Wrap lines at chars in 'breakat' rather than at last character.
set linebreak
" Wrapped lines should have the same amount of indentation
set breakindent
" Put `\ ` before wrapped lines
let &showbreak = '\ '
" Replace concealable characters
set conceallevel=1
" Do not automatically open folds when searching
set foldopen-=search
if (exists('g:loaded_gitgutter'))
	" Augment the default `foldtext()` with an indicator whether the folded
	" lines have been changed.
	set foldtext=gitgutter#fold#foldtext()
endif

" Netrw
" Use tree style listing
let g:netrw_liststyle=3


" TermDebug
" Have source view to the side of the splits of debugger and program
let g:termdebug_wide = 1
