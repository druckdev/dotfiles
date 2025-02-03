" Automatic formatting of paragraphs. Trailing white space indicates a paragraph
" continues in the next line.
setlocal formatoptions+=aw

" Turn on line-wrapping
setlocal wrap

" Fold by sections
function! MdSectionFold()
	let depth = len(matchstr(getline(v:lnum), '^#*'))
	return depth ? ">" . depth : "="
endfunction
setlocal foldmethod=expr foldexpr=MdSectionFold()
" Unfold everything when opening
normal zR
