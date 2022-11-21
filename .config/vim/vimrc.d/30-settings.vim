" Settings """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" hybrid linenumbers
set number relativenumber
augroup numbertoggle
	au!
	au BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
	au BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END
" no timeout when exiting insert-mode
" (see https://www.johnhawthorn.com/2012/09/vi-escape-delays/)
set timeoutlen=1000 ttimeoutlen=0
" smart case insensitive search (insens: /copy /Copy\c; sens: /Copy /copy\C)
set ignorecase smartcase
" Tab size
set tabstop=4
" Shift the same amount as tabstop
set shiftwidth=0
" Auto-wrap text and comments; automatically add comment leader when creating
" new lines and delete it when joining; do not break already too long lines;
" allow formatting with gq. Recognize numbered lists when formatting.
set formatoptions=tcroqljn
" Autoindent new lines
set autoindent
" Copy structure of the existing lines indent when autoindenting a new line
set copyindent
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
"set cursorline
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
set listchars=tab:>·
" Keep current line away from top/bottom borders of the buffer when scrolling
set scrolloff=15
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
" Wrap lines at chars in 'breakat' rather than at last character.
set linebreak
" Wrapped lines should have the same amount of indentation
set breakindent
" Put `\ ` before wrapped lines
let &showbreak = '\ '

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
augroup termdebug_settings
	au!
	autocmd SourcePost termdebug.vim let g:termdebug_wide = 1
augroup end
