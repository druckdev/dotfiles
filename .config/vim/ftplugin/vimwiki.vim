" Don't highlight Unicode table separator (e.g. vertical box drawing character).
" See vimrc.d/aesthetics.vim for w:ignore_non_ascii_chars
if vimwiki#vars#get_syntaxlocal('rxTableSep') !~ '[\d0-\d127]'
	let w:ignore_non_ascii_chars = vimwiki#vars#get_syntaxlocal('rxTableSep')
	                             \ .. get(w:, 'ignore_non_ascii_chars', '')
	" Update after changes
	call HighlightNonASCIIChars()
endif
