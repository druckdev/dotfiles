" Looks """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use 24-bit (true-color) mode
if (has('termguicolors'))
	set termguicolors
	" https://github.com/vim/vim/issues/993
	if (&term != 'xterm-256color')
		" set Vim-specific sequences for RGB colors
		let &t_8f = "\e[38;2;%lu;%lu;%lum"
		let &t_8b = "\e[48;2;%lu;%lu;%lum"
	endif
endif
" use onedark as theme for syntax highlighting
syntax on
colorscheme onedark

" get transparent background of the terminal back
" (at least in nvim, i can't get it to work in vanilla)
if (has('nvim'))
	highlight Normal guibg=NONE
	highlight NonText guibg=NONE
endif

if (get(g:, 'loaded_fzf'))
	" Use theme colors in fzf
	let g:fzf_colors = {
		\ 'fg':      ['fg', 'Normal'],
		\ 'bg':      ['bg', 'Normal'],
		\ 'hl':      ['fg', 'Comment'],
		\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
		\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
		\ 'hl+':     ['fg', 'Statement'],
		\ 'info':    ['fg', 'PreProc'],
		\ 'border':  ['fg', 'Ignore'],
		\ 'prompt':  ['fg', 'Conditional'],
		\ 'pointer': ['fg', 'Exception'],
		\ 'marker':  ['fg', 'Keyword'],
		\ 'spinner': ['fg', 'Label'],
		\ 'header':  ['fg', 'Comment']
	\ }
	" Use a theme for bat in the preview that somewhat resembles onedark
	let $BAT_THEME='TwoDark'

	" Increase size of fzf window and make it span over full window when in
	" tmux
	if exists('$TMUX')
		let g:fzf_layout = { 'tmux': '95%,90%' }
	else
		let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.9 }}
	endif
endif

" Get red from my colorscheme
let s:red = {}
if exists("*onedark#GetColors")
	let s:red = onedark#GetColors()->get("red", {})
endif
let s:red_cterm = s:red->get("cterm", "red")
let s:red_gui = s:red->get("gui", "red")

" Highlight trailing whitespaces
if match(&listchars, 'trail: \@!') > -1 && match(&listchars, '\vtab:( +)@!') > -1
	" Use foreground for coloring if tabs and trailing spaces are displayed
	" as non-space characters
	execute "highlight TrailingWhitespace ctermfg=" .. s:red_cterm
	                                 \ .. " guifg=" .. s:red_gui
else
	" Background otherwise
	execute "highlight TrailingWhitespace ctermbg=" .. s:red_cterm
	                                 \ .. " guibg=" .. s:red_gui
endif
augroup HighlightTrailingWhitespace
	au!
	" Pattern taken from
	" https://vim.fandom.com/wiki/Highlight_unwanted_spaces
	"
	" NOTE: VimEnter is necessary as well, since WinNew is not triggered for
	" the first window created after startup (see :help WinNew)
	au VimEnter,WinNew * call matchadd("TrailingWhitespace", '\s\+\%#\@<!$')
augroup END

let g:spl_special_chars = {
	\ 'de': 'äöüßÄÖÜ',
	\ 'fr': 'àâæçèéêëîïôœùûüÿÀÂÆÇÈÉÊËÎÏÔŒÙÛÜŸ',
\ }

" Highlight non-ASCII characters in red
execute "highlight NonASCIIChars ctermfg=white guifg=white "
	\ .. "ctermbg=" .. s:red_cterm .. " guibg=" .. s:red_gui

" Do not highlight special characters that are valid in the respective spelllang
function! HighlightNonASCIIChars()
	if exists('w:non_ascii_match_id')
		call matchdelete(w:non_ascii_match_id)
	endif

	let l:ignore_chars = '\d0-\d127'
	for l:spl in keys(g:spl_special_chars)
		if (&spelllang =~ '\v(^|,)' . l:spl . '($|,)')
			let l:ignore_chars ..= g:spl_special_chars[l:spl]
		endif
	endfor

	if exists('w:ignore_non_ascii_chars')
		let l:ignore_chars ..= w:ignore_non_ascii_chars
	endif

	let w:non_ascii_match_id = matchadd('NonASCIIChars',
	                                  \ '[^' .. l:ignore_chars .. ']')
endfunction
" Create the highlight when entering a new window, and update it if spelllang
" changes
augroup HighlightNonASCIIChars
	au!
	au OptionSet spelllang call HighlightNonASCIIChars()
	au VimEnter,WinNew * call HighlightNonASCIIChars()
augroup END

" Helpful for debugging syntax highlighting. Taken from:
" https://jordanelver.co.uk/blog/2015/05/27/working-with-vim-colorschemes/
"
" Also useful (List all groups):
" :so $VIMRUNTIME/syntax/hitest.vim
function! <SID>SynStack()
	if !exists("*synstack")
		return
	endif
	echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nmap <leader>sp :call <SID>SynStack()<CR>
