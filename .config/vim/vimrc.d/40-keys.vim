" vim: set foldmethod=marker:
" Keybindings """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stop highlighting search result when pressing Return
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Indentation jump
" https://vim.fandom.com/wiki/Move_to_next/previous_line_with_same_indentation
" noremap <silent> <C-k> :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<CR>
" noremap <silent> <C-j> :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<CR>

" Split view navigation
" Create new panes
nnoremap <C-w>N <Cmd>vsplit<CR>
nnoremap <C-w>n <Cmd>split<CR>

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
map <leader>st <Cmd>set spell!<CR>
map <leader>sc <Cmd>call CycleSpellLang()<CR>
map <leader>ss :set spelllang=

" Jump through jump table but center while still respecting 'foldopen'
noremap <expr> <C-I> '<C-I>' . (match(&fdo, 'mark') > -1 ? 'zv' : '') . 'zz'
noremap <expr> <C-O> '<C-O>' . (match(&fdo, 'mark') > -1 ? 'zv' : '') . 'zz'
nmap <Tab> <C-I>
nmap <S-Tab> <C-O>

" Terminal
if (has('nvim'))
	tnoremap <leader><Esc> <C-\><C-n>
	nmap <leader><CR> :split +terminal<CR>i
	nmap <leader>v<CR> :vsplit +terminal<CR>i
elseif (has('terminal'))
	nmap <leader><CR> <Cmd>terminal<CR>
endif

" Plugin specific bindings
if (get(g:, 'loaded_fzf'))
	nmap <leader>f <Cmd>Files<CR>
	nmap <leader>j <Cmd>Lines<CR>
	nmap <leader>/ <Cmd>Lines<CR>
	nmap <leader>h <Cmd>Helptags<CR>
	" TODO: fix this?
	if (get(g:, 'loaded_gutentags') || 1)
		nmap <leader>t <Cmd>Tags<CR>
		nmap <leader>bt <Cmd>BTags<CR>
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
nmap <leader>g* :let @/ = expand('<cword>') <bar>
             \  set hlsearch <bar>
             \  Rg <C-R>=expand('<cword>')<CR><CR>

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
nmap <leader>ga <Cmd>!git add -- %<CR>
nmap <leader>gs <Cmd>!git stash -- %<CR>
nmap <leader>gu <Cmd>!git checkout -- %<CR>

if exists('g:loaded_fugitive')
	" Interactive `git status`
	nmap <leader>gg <Cmd>G<CR>
	" Start a commit and open the message in a split
	nmap <leader>gcc <Cmd>G commit<CR>
	" Amend the current commit and open the message in a split
	nmap <leader>gca <Cmd>G commit --amend<CR>
	" Move to root of directory
	nmap <leader>gcd <Cmd>Gcd<CR>
	" git blame in scroll bound vertical split (only the commit hashes, see
	" :help :Git_blame)
	nmap <leader>gb :G blame<CR>C
else
	" Move to root of directory
	" NOTE: only works if a file is already opened
	nnoremap <leader>gcd <Cmd>cd %:h <Bar> cd `git rev-parse --show-toplevel`<CR>
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
	" Same for hunk navigation bindings + center line
	nmap [h <Plug>(GitGutterPrevHunk)zz
	nmap ]h <Plug>(GitGutterNextHunk)zz
endif

if (get(g:, 'loaded_fzf'))
	" git files that `git status` lists
	nmap <leader>gf <Cmd>GFiles?<CR>
	" 'git log (log?)' and 'git log buffer '
	map <leader>gll <Cmd>Commits<CR>
	map <leader>glb <Cmd>BCommits<CR>
endif

" Y should behave like D & C does
nnoremap Y y$

" Clear line (`cc` but stay in normal mode)
nmap <leader>dd 0D

" Fix & command to also use last flags
nnoremap & <Cmd>&&<CR>
xnoremap & <Cmd>&&<CR>

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
	let l:mappings = {
		\ 'j':  'gj',
		\ 'k':  'gk',
		\ '0':  'g0',
		\ '^':  'g^',
		\ '$':  'g$',
		\ 'gj': 'j',
		\ 'gk': 'k',
		\ 'g0': '0',
		\ 'g^': '^',
		\ 'g$': '$',
	\ }
	if &wrap
		for [l:from, l:to] in items(l:mappings)
			execute 'noremap ' .. l:from .. ' ' .. l:to
		endfor
	else
		for l:key in keys(l:mappings)
			execute 'silent! unmap ' .. l:key
		endfor
	endif
endfunction
augroup WrapMovementMappings
	au!
	au OptionSet wrap call MapWrapMovement()
augroup END

" Convert Unix timestamp to human readable
" Mnemonic: "Unix timestamp convert" with pun to UTC
nnoremap <leader>utc ciw<C-r>=strftime("%F %T", @")<CR><Esc>
vnoremap <leader>utc <Cmd>s/\v(^\|[^0-9])\zs[0-9]{10}\ze([^0-9]\|$)/\=strftime("%F %T",submatch(0))/g<CR>

" Match the behaviour of [[ and []. ]] forward to next '}' in the first column
" and ][ fw to next '[', instead of the other way around.
noremap ]] ][
noremap ][ ]]

" Strip trailing whitespace
nnoremap <leader><space> <Cmd>silent! %s/\v\s+$//<CR>
vnoremap <leader><space> <Cmd>silent! '<,'>s/\v\s+$//<CR>

" Convert double quotes to single. Convert only pairs to lower the false
" positive rate.
nnoremap <leader>" <Cmd>silent! %s/\v"([^"]*)"/'\1'/g<CR>
vnoremap <leader>" <Cmd>silent! '<,'>s/\v"([^"]*)"/'\1'/g<CR>

" Keep selection when changing the indentation in visual mode
vnoremap > >gv
vnoremap < <gv
vnoremap = =gv

" Center search results while still respecting 'foldopen'
" TODO: This does not trigger hlsearch
function! s:CenterNext(count, command)
	let l:foldopen = match(&foldopen, 'search') > -1 ? 'zv' : ''

        " Search count (i.e. [5/10]) will not display with 'lazyredraw'
	let l:lazyredraw_bkp = &lazyredraw
	set nolazyredraw

	execute 'normal! ' .. a:count .. a:command .. l:foldopen .. 'zz'

	let &lazyredraw = l:lazyredraw_bkp
endfunction
map n <Cmd>call <SID>CenterNext(v:count1, 'n')<CR>
map N <Cmd>call <SID>CenterNext(v:count1, 'N')<CR>

cnoremap <expr> <CR> "<CR>" .
	\ (getcmdtype() == '/' \|\| getcmdtype() == '?'
		\ ? (match(&fdo, 'search') > -1 ? 'zv' : '') . "zz"
		\ : "")

" Switch to lower/upper case
nnoremap <leader><C-U> gUl
vnoremap <leader><C-U> gU
nnoremap <leader><C-L> gul
vnoremap <leader><C-L> gu

" Expand visual selection over all directly following lines in the given
" direction that contain the current selection at the same position.
"
" Example:
" ```
"  - TODO: ...
"  - TODO: ...
"  - TODO: ...
" ```
"
" In visual block one can select `TODO: ` on the first line and then call
" `ExpandVisualSelection(1)` which results in a block selection that spans over
" all other TODOs as well.
function! ExpandVisualSelection(direction)
	let l:sel = escape(GetVisualSelection(), '\')
	normal gv

	" Move the cursor onto the side of the selection that points in the
	" direction of the expansion.
	let l:swap_ends = 0
	if (
			\ (getpos('.') == getpos("'>") && a:direction < 0) ||
			\ (getpos('.') == getpos("'<") && a:direction > 0)
	\)
		normal o
		let l:swap_ends = 1
	endif

	if (a:direction < 0)
		" Because of the greedy nature of search(), we cannot use the same
		" regex/approach as when searching forwards, as it will only ever match
		" the preceding line.
		while (
				\ (line('.') - 1) &&
				\ match(getline(line('.') - 1), '\%'.col("'<").'c'.l:sel) != -1
		\)
			call cursor(line('.') - 1, col("'<"))
		endwhile
	elseif (a:direction > 0)
		let l:pat = '\v%#(.*\n.*%' . col("'<") . 'c\V' . l:sel . '\)\*'
		call search(l:pat, 'e')
	else
		" TODO: expand in both directions
	endif

	" Reset cursor column
	if (l:swap_ends && mode() == "\<C-V>")
		normal O
	endif
endfunction

vmap <silent> <leader>j <Cmd>call ExpandVisualSelection(1)<CR>
vmap <silent> <leader>k <Cmd>call ExpandVisualSelection(-1)<CR>

let g:macro_type_mappings = {
	\ '<Space>': '_',
\ }

function! s:macro_type()
	if !exists('s:macro_type')
		let s:macro_type = 0
	endif

	if !s:macro_type
		let s:macro_type = 1

		" Disable on InsertLeave
		au! macro_type InsertLeave * call s:macro_type()

		for [l:from, l:to] in items(g:macro_type_mappings)
			execute 'imap ' .. l:from .. ' ' .. l:to
		endfor

		for l:key in "abcdefghijklmnopqrstuvwxyz"
			execute 'imap ' .. l:key .. ' ' .. toupper(l:key)
		endfor
	else
		let s:macro_type = 0
		au! macro_type

		for l:key in keys(g:macro_type_mappings)
			execute 'iunmap ' .. l:key
		endfor

		for l:key in "abcdefghijklmnopqrstuvwxyz"
			execute 'iunmap ' .. l:key
		endfor
	endif
endfunction

" Type everything uppercase and underscores instead of spaces
noremap <leader>mac <Cmd>call <sid>macro_type()<CR>i
augroup macro_type
	au!
augroup END
