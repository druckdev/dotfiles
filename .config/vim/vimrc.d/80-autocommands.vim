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
		" Do not highlight trailing whitespace in terminal windows
		autocmd TermOpen * silent! call
			\ matchdelete(filter(getmatches(), 'v:val["group"] == "TrailingWhitespace"')[0]["id"])
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
	" Go to normal mode with <Esc> like usually
	autocmd SourcePost termdebug.vim tnoremap <Esc> <C-\><C-n>
augroup END

" Highlight word under cursor in other places
function! s:highlight_cword()
	if exists('w:disable_highlight_cword')
		return
	endif

	if get(w:, 'old_cword', '') == expand('<cword>')
		" Nothing to do if we're still on the same word
		return
	endif

	" Clear previous highlight and kill the possibly already running timer
	call s:clear_highlights(s:CLEAR_HIGHS_CWORD)

	" Delay the highlight by 100ms so that not every word is highlighted
	" while moving the cursor fast. (This kind of simulates a CursorHold
	" event with a custom time)
	let w:cword_timer_id = timer_start(100, "s:_highlight_cword")
endfunction

function! s:_highlight_cword(timer_id)
	" TODO: this should never exist, but sometimes it does. How? To reproduce:
	"       Select something and then <leader>nr.
	if exists('w:cword_match_id')
		return
	endif
	unlet w:cword_timer_id

	let l:cword = expand('<cword>')
	if (l:cword != '')
		let w:old_cword = l:cword
		let w:cword_match_id = matchadd(
			\ 'CursorColumn',
			\ '\V\<' . escape(l:cword, '/\') . '\>',
			\ -1)
	endif
endfunction

" Highlight visual selection in other places
function! s:highlight_selection()
	if exists('w:disable_highlight_visual_sel')
		return
	endif

	" Kill the possibly already running timer
	if exists('w:selection_timer_id')
		call timer_stop(w:selection_timer_id)
	endif

	" Delay the highlight by 100ms so that not every selection is highlighted
	" while moving the cursor fast. (This kind of simulates a CursorHold
	" event with a custom time)
	let w:selection_timer_id = timer_start(100, "s:_highlight_selection")
endfunction

function! s:_highlight_selection(timer)
	unlet w:selection_timer_id

	let l:old_reg = getreg('"')
	let l:old_regtype = getregtype('"')
	" NOTE: The yank needs to be silent to mute the 'n lines yanked'
	" message. But the `silent` leads to the disappearance of the selection
	" size indicator (:h 'showcmd'), thus `y` and `gv` need to be executed
	" in separate normal mode commands.
	silent normal y
	normal gv

	if @" == "" || @" == "\n"
		" Abort when visual mode started on an empty line
		return
	endif

	if !exists('w:visual_match_ids')
		let w:visual_match_ids = {}
	endif

	" Add match to all windows containing the current buffer
	" NOTE: This does not delete the matches for windows that do not exist
	"       anymore, but I don't think that this is an issue and
	"       clear_highlights deletes them later on mode change.
	for l:win in win_findbuf(bufnr())
		if exists("w:visual_match_ids[l:win]")
			call matchdelete(w:visual_match_ids[l:win], l:win)
		endif
		" NOTE: \%V\@! prevents the pattern from matching the current selection.
		"       As it is highlighted already this would be superfluous and
		"       inefficient.
		let w:visual_match_ids[l:win] =
			\ matchadd(
				\ 'CursorColumn',
				\ '\V\%V\@!' . substitute(escape(@", '\'), '\n', '\\n', 'g'),
				\ -1,
				\ -1,
				\ {'window': l:win})
	endfor

	call setreg('"', l:old_reg, l:old_regtype)
endfunction

" Clear the highlights of <cword> and visual selection
function! s:clear_highlights(what = s:CLEAR_HIGHS_ALL)
	if and(a:what, s:CLEAR_HIGHS_CWORD)
		if exists('w:cword_timer_id')
			call timer_stop(w:cword_timer_id)
			unlet w:cword_timer_id
		endif
		if exists('w:cword_match_id')
			call matchdelete(w:cword_match_id)
			unlet w:cword_match_id
			unlet w:old_cword
		endif
	endif
	if and(a:what, s:CLEAR_HIGHS_VISUAL)
		if exists('w:selection_timer_id')
			call timer_stop(w:selection_timer_id)
			unlet w:selection_timer_id
		endif
		if exists('w:visual_match_ids')
			for [l:win, l:id] in items(w:visual_match_ids)
				call matchdelete(l:id, l:win)
			endfor
			unlet w:visual_match_ids
		endif
	endif
endfunction

augroup highlight_current
	au!
	" TODO: `viw` when on the last character of the word does not trigger
	"       CursorMoved, but the selection changes
	au CursorMoved * if mode() == 'n' |
	               \     call s:highlight_cword() |
	               \ else |
	               \     call s:highlight_selection() |
	               \ endif
	au CursorMovedI * call s:highlight_cword()
	au WinLeave * call s:clear_highlights()
	au ModeChanged [vV\x16]*:* call s:clear_highlights(s:CLEAR_HIGHS_VISUAL) | call s:highlight_cword()
	" NOTE: s:highlight_selection is not called when entering non-linewise visual
	"       mode as I rarely need one-character highlighting and I can work
	"       around by moving back and forth once.
	" TODO: Fix for other ways of entering with a longer selection
	au ModeChanged *:[v\x16]* call s:clear_highlights(s:CLEAR_HIGHS_CWORD)
	au ModeChanged *:V call s:clear_highlights(s:CLEAR_HIGHS_CWORD) | call s:highlight_selection()
augroup END

" When switching focus to another window, keep the cursor location underlined.
function! s:highlight_old_cursor_pos()
	let w:cursor_pos_match_id = matchaddpos(
		\ 'Underlined',
		\ [getcurpos()[1:2]])
endfunction
function! s:clear_old_cursor_pos()
	if exists('w:cursor_pos_match_id')
		call matchdelete(w:cursor_pos_match_id)
		unlet w:cursor_pos_match_id
	endif
endfunction
augroup highlight_old_cursor_pos
	au!
	au WinLeave * call s:highlight_old_cursor_pos()
	au WinEnter * call s:clear_old_cursor_pos()

	" TODO: WinLeave is not triggered when entering command line mode and
	"       CmdlineEnter is triggered **after** entering
	" nnoremap : :call s:highlight_old_cursor_pos()<CR>:
	" au CmdlineLeave * call s:clear_old_cursor_pos()
augroup END

" Do not mark input from stdin as modified
augroup stdin_not_modified
	au!
	au StdinReadPost * set nomodified
augroup END
