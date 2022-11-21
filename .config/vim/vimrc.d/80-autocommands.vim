" Autocommands """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal
if (has('nvim'))
	" Disable spellcheck
	augroup terminal_no_spellcheck
		au!
		autocmd TermOpen * setlocal nospell
	augroup END
endif

" change cursor shape depending on mode
augroup cursor_shape_by_mode
au!
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
augroup END

" Custom bindings when debugging
augroup termdebug_bindings
	au!
	autocmd SourcePost termdebug.vim tnoremap <Esc> <C-\><C-n>
augroup END

" Highlight word under cursor
function! HighlightCurrentWord()
	if exists('w:cword_match_id')
		call matchdelete(w:cword_match_id)
		unlet w:cword_match_id
	endif
	if (expand('<cword>') != '')
		let w:cword_match_id = matchadd(
			\ 'CursorColumn',
			\ '\V\<' . escape(expand('<cword>'), '/\') . '\>',
			\ -1)
	endif
endfunction
augroup highlight_current_word
	au!
	au CursorMoved * call HighlightCurrentWord()
	au CursorMovedI * call HighlightCurrentWord()
augroup END

" When switching focus to another window, keep the cursor location highlighted.
function! HighlightOldCursorPos()
	let w:cursor_pos_match_id = matchaddpos(
		\ 'TermCursor',
		\ [getcurpos()[1:2]])
endfunction
function! ClearOldCursorPos()
	if exists('w:cursor_pos_match_id')
		echo 'foo'
		call matchdelete(w:cursor_pos_match_id)
		unlet w:cursor_pos_match_id
	endif
endfunction
augroup highlight_old_cursor_pos
	au!
	au WinLeave * call HighlightOldCursorPos()
	au WinEnter * call ClearOldCursorPos()

	" TODO: WinLeave is not triggered when entering command line mode and
	"       CmdlineEnter is triggered **after** entering
	" nnoremap : :call HighlightOldCursorPos()<CR>:
	" au CmdlineLeave * call ClearOldCursorPos()
augroup END

" Do not mark input from stdin as modified
augroup stdin_not_modified
	au!
	au StdinReadPost * set nomodified
augroup END

" Start in insert mode when opening a new file that does not exist yet
augroup newfile_insert
	au!
	autocmd BufNewFile * startinsert
augroup END
