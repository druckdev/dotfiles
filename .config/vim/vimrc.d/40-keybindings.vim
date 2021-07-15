" Keybindings """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stop highlighting search result when pressing Return
nnoremap <silent> <CR> :nohlsearch<CR><CR>

" Indentation jump
" https://vim.fandom.com/wiki/Move_to_next/previous_line_with_same_indentation
" noremap <silent> <C-k> :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<CR>
" noremap <silent> <C-j> :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<CR>

" Split view navigation
" Create new panes
nnoremap <C-w>N :vsplit<CR>
nnoremap <C-w>n :split<CR>
" Move between panes
nnoremap <C-h> <C-w><C-h>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>

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
if (has('clipboard') || has('nvim'))
	noremap <leader>y "+y
	noremap <leader>d "+d
	noremap <leader>p "+p
	noremap <leader>P "+P
endif

" Ctrl-Backspace should delete words in insert mode and on command-line.
noremap! <C-H> <C-W>

" Correct word with best/first suggestion.
noremap <leader>c 1z=

" Toggle spell, cycle and set spelllang
map <leader>st :set spell=!&spell<CR>
map <leader>sc :call CycleSpellLang()<CR>
map <leader>ss :set spelllang=
" Umlaute and sz in Insert and Command-line mode when spelllang is set to de
autocmd OptionSet spelllang call NewSpellLang(v:option_new, v:option_old)
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
	" tnoremap <Esc> <C-\><C-n>
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
	if (get(g:, 'loaded_gutentags'))
		nmap <leader>t :Tags<CR>
	endif
endif

" Search for selected text.
" Taken from https://vim.fandom.com/wiki/Search_for_visually_selected_text
vnoremap / y/\V<C-R>=escape(@",'/\')<CR><CR>

" Select last pasted text in same visual mode as it was selected (v, V, or ^V)
" Taken from: https://vim.fandom.com/wiki/Selecting_your_pasted_text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

if exists('g:loaded_fugitive')
	nnoremap <leader>cd :Gcd<CR>
else
	" only works if a file is already opened
	nnoremap <leader>cd :cd %:h <Bar> cd `git rev-parse --show-toplevel`<CR>
endif

" Y should behave like D & C does
nnoremap Y y$
