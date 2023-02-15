" Keybindings """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stop highlighting search result when pressing Return
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Indentation jump
" https://vim.fandom.com/wiki/Move_to_next/previous_line_with_same_indentation
" noremap <silent> <C-k> :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<CR>
" noremap <silent> <C-j> :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<CR>

" Split view navigation
" Create new panes
nnoremap <C-w>N :vsplit<CR>
nnoremap <C-w>n :split<CR>

" Substitute command
if (exists('+inccommand') && &inccommand != '')
	nnoremap S :%s/
	vnoremap S :s/
else
	" This does not work with live previewing commands (inccommand) since the
	" replace pattern is already defined and thus everything matching the search
	" pattern is just deleted.
	nnoremap S :%s//gc<Left><Left><Left>
	vnoremap S :s//gc<Left><Left><Left>
endif

" Interact with the system clipboard
if (has('clipboard'))
	map <leader>y "+y
	map <leader>Y "+Y
	map <leader>p "+p
	map <leader>P "+P
endif

" Ctrl-Backspace should delete words in insert mode and on command-line.
noremap! <C-BS> <C-W>
map! <C-H> <C-BS>

" Correct word with best/first suggestion.
noremap <leader>c 1z=
" Correct next or last misspelled word (and their non-rare/region versions)
" without moving
" TODO: see :keepjumps
"       Problem: with keepjumps the <C-O> is not possible anymore
noremap <leader>]s ]s1z=<C-O>
noremap <leader>[s [s1z=<C-O>
noremap <leader>]S ]S1z=<C-O>
noremap <leader>[S [S1z=<C-O>

" Toggle spell language between German and English
function! CycleSpellLang()
	if (&spelllang == 'en')
		setl spelllang=de
	else
		setl spelllang=en
	endif
endfunction
" Toggle spell, cycle and set spelllang
map <leader>st :set spell=!&spell<CR>
map <leader>sc :call CycleSpellLang()<CR>
map <leader>ss :set spelllang=

" Jump through jump table but center
noremap <Tab> <Tab>zz
noremap <C-O> <C-O>zz
nmap <S-Tab> <C-O>

" Terminal
if (has('nvim'))
	tnoremap <leader><Esc> <C-\><C-n>
	nmap <leader><CR> :split +terminal<CR>i
	nmap <leader>v<CR> :vsplit +terminal<CR>i
elseif (has('terminal'))
	nmap <leader><CR> :terminal<CR>
endif

" Plugin specific bindings
if (get(g:, 'loaded_fzf'))
	nmap <leader>f :Files<CR>
	nmap <leader>j :Lines<CR>
	nmap <leader>/ :Lines<CR>
	nmap <leader>h :Helptags<CR>
	" TODO: fix this?
	if (get(g:, 'loaded_gutentags') || 1)
		nmap <leader>t :Tags<CR>
		nmap <leader>bt :BTags<CR>
	endif
endif

" Search for selected text.
" Modified from https://vim.fandom.com/wiki/Search_for_visually_selected_text
function! GetVisualSelection()
	let l:old_reg = getreg('"')
	let l:old_regtype = getregtype('"')
	norm gvy
	let l:sel = getreg('"')
	call setreg('"', l:old_reg, l:old_regtype)
	return l:sel
endfunction

vmap * /\V<C-R>=escape(GetVisualSelection(),'/\')<CR><CR>
vmap # ?\V<C-R>=escape(GetVisualSelection(),'?\')<CR><CR>

" Extended `*`. Starts vim search (without jump) and ripgrep
nmap <leader>* :let @/ = '\<' . expand('<cword>') . '\>' <bar>
             \  set hlsearch <bar>
             \  Rg \b<C-R>=expand('<cword>')<CR>\b<CR>
vmap <leader>* :<C-U>let @/ = "\\V<C-R>=escape(escape(GetVisualSelection(), '\'), '"\')<CR>" <bar>
             \  set hlsearch <bar>
             \  Rg <C-R>=escape(GetVisualSelection(), '.\[]<bar>*+?{}^$()')<CR><CR>

" Search inside visual selection
noremap <leader>v/ /\%V
vmap <leader>/ <Esc><leader>v/

" Select last pasted text in same visual mode as it was selected (v, V, or ^V)
" Taken from: https://vim.fandom.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Git bindings

" Insert a commit's subject behind the SHA1 that the cursor is currently on.
" Mnemonic: "git reference commit"
" NOTE: This uses `system` and not `:r!` to insert the text directly at the
"       cursor. `subject[:-2]` cuts off the trailing newline.
nmap <leader>grc :let subject=system('git show -s --format="(\"%s\")" <C-R><C-W>')<CR>viw<Esc>a <C-R>=subject[:-2]<CR><Esc>

" Insert a Signed-off-by trailer
nmap <leader>gso :r!git config --get user.name<CR>:r!git config --get user.email<CR>I<<ESC>A><ESC>kJISigned-off-by: <ESC>

" Add, stash or checkout the current file
nmap <leader>ga :!git add -- %<CR>
nmap <leader>gs :!git stash -- %<CR>
nmap <leader>gu :!git checkout -- %<CR>

if exists('g:loaded_fugitive')
	" Interactive `git status`
	nmap <leader>gg :G<CR>
	" Start a commit and open the message in a split
	nmap <leader>gcc :G commit<CR>
	" Amend the current commit and open the message in a split
	nmap <leader>gca :G commit --amend<CR>
	" Move to root of directory
	nmap <leader>gcd :Gcd<CR>
	" git blame in scroll bound vertical split (only the commit hashes, see
	" :help :Git_blame)
	nmap <leader>gb :G blame<CR>C
else
	" Move to root of directory
	" NOTE: only works if a file is already opened
	nnoremap <leader>gcd :cd %:h <Bar> cd `git rev-parse --show-toplevel`<CR>
endif

if exists('g:loaded_gitgutter')
	" Add `g` prefix to hunk bindings
	" Mnemonic: "git hunk <add|undo|preview>"
	nmap <leader>gha <Plug>(GitGutterStageHunk)
	" TODO: nmap <leader>ghs <Plug>(GitGutterStashHunk)
	nmap <leader>ghu <Plug>(GitGutterUndoHunk)
	nmap <leader>ghp <Plug>(GitGutterPreviewHunk)

	" StageHunk can be used for single lines. Mnemonic w/o `h`unk
	xmap <leader>ga <Plug>(GitGutterStageHunk)

	" Add hunk/h version to textobject bindings that use `c` (for `change I
	" presume?) (e.g. ic -> ih)
	omap ih <Plug>(GitGutterTextObjectInnerPending)
	omap ah <Plug>(GitGutterTextObjectOuterPending)
	xmap ih <Plug>(GitGutterTextObjectInnerVisual)
	xmap ah <Plug>(GitGutterTextObjectOuterVisual)
	" Same for hunk navigation bindings
	nmap [h <Plug>(GitGutterPrevHunk)
	nmap ]h <Plug>(GitGutterNextHunk)
endif

if (get(g:, 'loaded_fzf'))
	" git files that `git status` lists
	nmap <leader>gf :GFiles?<CR>
	" 'git log (log?)' and 'git log buffer '
	map <leader>gll :Commits<CR>
	map <leader>glb :BCommits<CR>
endif

" Y should behave like D & C does
nnoremap Y y$

" Clear line (`cc` but stay in normal mode)
nmap <leader>dd 0D

" Fix & command to also use last flags
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" see :help i_ctrl-g_u
" Do not break undo sequence when using the arrow keys or home and end in insert
" mode
inoremap <Left>  <C-G>U<Left>
inoremap <Right> <C-G>U<Right>
inoremap <expr> <Home> col('.') == match(getline('.'), '\S') + 1 ?
	\ repeat('<C-G>U<Left>', col('.') - 1) :
	\ (col('.') < match(getline('.'), '\S') ?
	\     repeat('<C-G>U<Right>', match(getline('.'), '\S') + 0) :
	\     repeat('<C-G>U<Left>', col('.') - 1 - match(getline('.'), '\S')))
inoremap <expr> <End> repeat('<C-G>U<Right>', col('$') - col('.'))
" Make insert-mode texts repeatable by `.` with the closing parentheses at the
" right position
inoremap ( ()<C-G>U<Left>
" break undo sequence with every space and newline, making insert mode changes
" revertible in smaller chunks
inoremap <Space> <C-G>u<Space>
inoremap <CR> <C-G>u<CR>

" Open the manpage in the WORD under cursor
nnoremap gm :Man <C-r><C-a><CR>
xnoremap gm :Man <C-r><C-a><CR>

" Format the current paragraph, while keeping the cursor position
nmap Q gwap
imap <C-q> <C-o>Q

" Swap movement mappings that act on display lines with the normal ones, making
" it easier to navigate long wrapped lines.
function! MapWrapMovement()
	if &wrap
		noremap j gj
		noremap k gk
		noremap 0 g0
		noremap ^ g^
		noremap $ g$
		noremap gj j
		noremap gk k
		noremap g0 0
		noremap g^ ^
		noremap g$ $
	else
		noremap j j
		noremap k k
		noremap 0 0
		noremap ^ ^
		noremap $ $
		noremap gj gj
		noremap gk gk
		noremap g0 g0
		noremap g^ g^
		noremap g$ g$
	endif
endfunction
augroup WrapMovementMappings
	au!
	au OptionSet wrap call MapWrapMovement()
augroup END

" Convert Unix timestamp to human readable
" Mnemonic: "Unix timestamp convert" with pun to UTC
nnoremap <leader>utc ciw<C-r>=strftime("%F %T", @")<CR><Esc>
vnoremap <leader>utc :s/\v(^\|[^0-9])\zs[0-9]{10}\ze([^0-9]\|$)/\=strftime("%F %T",submatch(0))/g<CR>

" Match the behaviour of [[ and []. ]] forward to next '}' in the first column
" and ][ fw to next '[', instead of the other way around.
noremap ]] ][
noremap ][ ]]

" Strip trailing whitespace
nnoremap <leader><space> :silent! %s/\v\s+$//<CR>
vnoremap <leader><space> :<C-u>silent! '<,'>s/\v\s+$//<CR>

" Convert double quotes to single. Convert only pairs to lower the false
" positive rate.
nnoremap <leader>" :silent! %s/\v"([^"]*)"/'\1'/g<CR>
vnoremap <leader>" :<C-u>silent! '<,'>s/\v"([^"]*)"/'\1'/g<CR>

" Keep selection when changing the indentation in visual mode
vnoremap > >gv
vnoremap < <gv
vnoremap = =gv

" Center search results
noremap n nzz
noremap N Nzz
cnoremap <expr> <CR> "<CR>" .
	\ (getcmdtype() == '/' \|\| getcmdtype() == '?'
		\ ? "zz"
		\ : "")

" Switch to lower/upper case
nnoremap <leader><C-U> gUl
vnoremap <leader><C-U> gU
nnoremap <leader><C-L> gul
vnoremap <leader><C-L> gu
