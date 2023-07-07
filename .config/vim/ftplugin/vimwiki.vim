" Do not highlight vertical box drawing character as non-ASCII if it used as
" table separator
if vimwiki#vars#get_syntaxlocal('rxTableSep') == '│'
	let w:ignore_non_ascii_chars = '│' .. get(w:, 'ignore_non_ascii_chars', '')
	" Update after changes
	call HighlightNonASCIIChars()
endif
