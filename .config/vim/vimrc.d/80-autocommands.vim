" Autocommands """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight trailing whitespaces
" (https://vim.fandom.com/wiki/Highlight_unwanted_spaces)
" Create highlight group
highlight ExtraWhitespace ctermbg=red guibg=red
" Associate with patter (trailing whitespaces)
match ExtraWhitespace /\s\+$/
" apply not only to the first window
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" Do not match when typing at the end of a line
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" Reset when leaving insert mode
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" Clear all matches
autocmd BufWinLeave * call clearmatches()

" Terminal
if (has('nvim'))
	" Disable spellcheck
	autocmd TermOpen * setlocal nospell
endif

" change cursor shape depending on mode
if (has('nvim'))
	" Beam when exiting
	autocmd VimLeave * silent !echo -ne "\e[5 q"
else
	" https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
	" https://github.com/tmux/tmux/issues/1593
	if exists('$TMUX')
		" Start insert mode - vertical bar/beam
		let &t_SI = "\ePtmux;\e\e[5 q\e\\"
		" Start replace mode - horizontal bar/underline
		let &t_SR = "\ePtmux;\e\e[3 q\e\\"
		" End insert or replace mode - block
		let &t_EI = "\ePtmux;\e\e[1 q\e\\"

		" Block when entering
		autocmd VimEnter * silent !echo -ne "\ePtmux;\e\e[1 q\e\\"
		" Beam when exiting
		autocmd VimLeave * silent !echo -ne "\ePtmux;\e\e[5 q\e\\"
	else
		" Start insert mode - vertical bar/beam
		let &t_SI = "\e[5 q"
		" Start replace mode - horizontal bar/underline
		let &t_SR = "\e[3 q"
		" End insert or replace mode - block
		let &t_EI = "\e[1 q"

		" Block when entering
		autocmd VimEnter * silent !echo -ne "\e[1 q"
		" Beam when exiting
		autocmd VimLeave * silent !echo -ne "\e[5 q"
	endif
endif
