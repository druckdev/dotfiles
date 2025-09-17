" Turn on line-wrapping
setlocal wrap
" Disable C-indentation as it messes up formatting of paragraphs containing
" parentheses
setlocal nocindent

" Fold by sections
function! MdSectionFold()
	let depth = len(matchstr(getline(v:lnum), '^#*'))
	return depth ? ">" . depth : "="
endfunction
setlocal foldmethod=expr foldexpr=MdSectionFold()
" Unfold everything when opening
normal zR
