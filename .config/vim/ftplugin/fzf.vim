" SPDX-License-Identifier: MIT
" Copyright (c) 2024 - 2025 Julian Prein

" Do not highlight Unicode chars used by the fzf TUI. For this ignore the:
"
" - Unicode "Box Drawing" block
" - Unicode "Block Elements" block
" - Unicode "Block elements" subblock of the "Symbols for Legacy Computing"
"   block (i.e. 1/8th block symbols)
" - Braille symbols for spinner
" - Ellipses and wrap signs for long lines
" - Line ending indicators
let w:ignore_non_ascii_chars =
	\ get(w:, 'ignore_non_ascii_chars', '') ..
	\ '\u2500-\u257f' ..
	\ '\u2580-\u259f' ..
	\ '\U0001fb70-\U0001fb89' ..
	\ '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' ..
	\ '·↳' ..
	\ '␍␊'

" Update after changes
call HighlightNonASCIIChars()

" vim: set ft=vim.fzf:
