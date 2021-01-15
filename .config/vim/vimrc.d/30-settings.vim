" Settings #####################################################################
" hybrid linenumbers
set number relativenumber
" no timeout when exiting insert-mode
" (see https://www.johnhawthorn.com/2012/09/vi-escape-delays/)
set timeoutlen=1000 ttimeoutlen=0
" smart case insensitive search (insens: /copy /Copy\c; sens: /Copy /copy\C)
set ignorecase smartcase
" Tab size
set tabstop=4
" Shift the same amount as tabstop
set shiftwidth=0
" Highlight current line
set cursorline
" Auto-wrap text and comments; automatically add comment leader when creating
" new lines and delete it when joining; do not break already too long lines;
" allow formatting with gq.
set formatoptions=tcroqlj
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
" Show the effect of a command while typing (substitute)
if (has('nvim'))
	set inccommand=nosplit
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
" Show ruler at 80 columns
set colorcolumn=80
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