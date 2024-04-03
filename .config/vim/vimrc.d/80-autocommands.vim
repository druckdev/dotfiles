" Autocommands """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Bitfield for highlight_current augroup
if !exists('s:CLEAR_HIGHS_ALL')
	const s:CLEAR_HIGHS_CWORD = 1
	const s:CLEAR_HIGHS_VISUAL = 2
	const s:CLEAR_HIGHS_ALL = 3
endif

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

" Highlight word under cursor in other places
function! HighlightCurrentWord()
	if exists('w:disable_highlight_cword')
		return
	endif

	let l:cword = expand('<cword>')
	if exists('w:old_cword') && w:old_cword == l:cword
		" Do not delete and readd the match if on the same word
		return
	endif

	call ClearHighlights()

	if (l:cword != '')
		let w:old_cword = l:cword
		let w:cword_match_id = matchadd(
			\ 'CursorColumn',
			\ '\V\<' . escape(l:cword, '/\') . '\>',
			\ -1)
	endif
endfunction

" Highlight visual selection in other places
function! HighlightVisualSel()
	if exists('w:disable_highlight_visual_sel')
		return
	endif

	call ClearHighlights()

	let l:old_reg = getreg('"')
	let l:old_regtype = getregtype('"')
	silent! norm ygv

	let w:visual_match_ids = []

	" Add match to all windows containing the current buffer
	for l:win in win_findbuf(bufnr())
		let w:visual_match_ids += [[
			\ matchadd(
				\ 'CursorColumn',
				\ '\V' . substitute(escape(@", '\'), '\n', '\\n', 'g'),
				\ -1,
				\ -1,
				\ {'window': l:win}),
			\ l:win
		\ ]]
	endfor

	call setreg('"', l:old_reg, l:old_regtype)
endfunction

" Clear the highlights of <cword> and visual selection
function! ClearHighlights(what = s:CLEAR_HIGHS_ALL)
	if and(a:what, s:CLEAR_HIGHS_CWORD) && exists('w:cword_match_id')
		call matchdelete(w:cword_match_id)
		unlet w:cword_match_id
		unlet w:old_cword
	endif
	if and(a:what, s:CLEAR_HIGHS_VISUAL) && exists('w:visual_match_ids')
		for l:pairs in w:visual_match_ids
			let l:id = l:pairs[0]
			let l:win = l:pairs[1]
			call matchdelete(l:id, l:win)
		endfor
		unlet w:visual_match_ids
	endif
endfunction

augroup highlight_current
	au!
	au CursorMoved * if mode() == 'n' |
	               \     call HighlightCurrentWord() |
	               \ else |
	               \     call HighlightVisualSel() |
	               \ endif
	au CursorMovedI * call HighlightCurrentWord()
	au WinLeave * call ClearHighlights()
	au ModeChanged [vV\x16]*:* call ClearHighlights(s:CLEAR_HIGHS_VISUAL) | call HighlightCurrentWord()
	au ModeChanged *:[vV\x16]* call ClearHighlights(s:CLEAR_HIGHS_CWORD) | call HighlightVisualSel()
augroup END

" When switching focus to another window, keep the cursor location underlined.
function! HighlightOldCursorPos()
	let w:cursor_pos_match_id = matchaddpos(
		\ 'Underlined',
		\ [getcurpos()[1:2]])
endfunction
function! ClearOldCursorPos()
	if exists('w:cursor_pos_match_id')
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
