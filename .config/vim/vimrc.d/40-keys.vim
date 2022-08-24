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
	map <leader>d "+d
	map <leader>p "+p
	map <leader>P "+P
endif

" Ctrl-Backspace should delete words in insert mode and on command-line.
noremap! <C-H> <C-W>

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

" Toggle spell, cycle and set spelllang
map <leader>st :set spell=!&spell<CR>
map <leader>sc :call CycleSpellLang()<CR>
map <leader>ss :set spelllang=
" Umlaute and sz in Insert and Command-line mode when spelllang is set to `de`
autocmd OptionSet spelllang silent call NewSpellLang(v:option_new, v:option_old)
function! NewSpellLang(new_lang, old_lang)
	let &spellfile = $XDG_DATA_HOME . '/vim/spell/' . a:new_lang . '.utf-8.add'

	let mappings = {
	\ 'ae': 'ä',
	\ 'Ae': 'Ä',
	\ 'oe': 'ö',
	\ 'Oe': 'Ö',
	\ 'ue': 'ü',
	\ 'Ue': 'Ü',
	\ 'sz': 'ß',
	\ }
	if (a:new_lang == 'de')
		for [key, value] in items(mappings)
			execute 'map! <buffer>' key value
		endfor
	elseif (a:old_lang == 'de')
		for key in keys(mappings)
			execute 'unmap! <buffer>' key
		endfor
	endif
endfunction

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
	endif
endif

" Search for selected text.
" Taken from https://vim.fandom.com/wiki/Search_for_visually_selected_text
vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>
vnoremap # y?\V<C-R>=escape(@",'?\')<CR><CR>

" Select last pasted text in same visual mode as it was selected (v, V, or ^V)
" Taken from: https://vim.fandom.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Git bindings

nmap <leader>gg :G<CR>

" Insert a commit's subject behind the SHA1 that the cursor is currently on.
" Mnemonic: "git reference commit"
" NOTE: This uses `system` and not `:r!` to insert the text directly at the
"       cursor. `subject[:-2]` cuts off the trailing newline.
nmap <leader>grc :let subject=system('git show -s --format="(\"%s\")" <C-R><C-W>')<CR>ea <C-R>=subject[:-2]<CR><Esc>

" Add, stash or checkout the current file
nmap <leader>ga :!git add -- %<CR>
nmap <leader>gs :!git stash -- %<CR>
nmap <leader>gu :!git checkout -- %<CR>

if exists('g:loaded_fugitive')
	" Using fugitive.vim, start a commit and open the message in a new split
	nmap <leader>gc :G commit<CR>
	" Move to root of directory
	nmap <leader>gcd :Gcd<CR>
else
	" Move to root of directory
	" NOTE: only works if a file is already opened
	nnoremap <leader>gcd :cd %:h <Bar> cd `git rev-parse --show-toplevel`<CR>
endif

if exists('g:loaded_gitgutter')
	" Add `g` prefix to hunk bindings

	" Mnemonic: "git hunk <add|undo|preview>"
	nmap <leader>gha <Plug>(GitGutterStageHunk)
	xmap <leader>gha <Plug>(GitGutterStageHunk)
	" TODO: nmap <leader>ghs <Plug>(GitGutterStashHunk)
	nmap <leader>ghu <Plug>(GitGutterUndoHunk)
	nmap <leader>ghp <Plug>(GitGutterPreviewHunk)

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

" Y should behave like D & C does
nnoremap Y y$

" Move lines up and down while correcting the indentation
" https://vim.fandom.com/wiki/Moving_lines_up_or_down
" (Use arrows, as Alt-{j,k} is used by my terminal for scrollback)
nnoremap <silent> <A-Up> :m .-2<CR>==
nnoremap <silent> <A-Down> :m .+1<CR>==
vnoremap <silent> <A-Up> :m '<-2<CR>gv=gv
vnoremap <silent> <A-Down> :m '>+1<CR>gv=gv
inoremap <silent> <A-Up> <Esc>:m .-2<CR>==gi
inoremap <silent> <A-Down> <Esc>:m .+1<CR>==gi

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

" Format the current paragraph
nmap Q gqap

" Convert Unix timestamp to human readable
" Mnemonic: "Unix timestamp convert" with pun to UTC
nnoremap <leader>utc ciw<C-r>=strftime("%F %T", @")<CR><Esc>
vnoremap <leader>utc :s/\v(^\|[^0-9])\zs[0-9]{10}\ze([^0-9]\|$)/\=strftime("%c",submatch(0))/g<CR>
