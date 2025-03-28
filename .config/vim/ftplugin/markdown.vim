" SPDX-License-Identifier: MIT
" Copyright (c) 2022 - 2025 Julian Prein

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
