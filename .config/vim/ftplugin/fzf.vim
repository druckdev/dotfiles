" Do not highlight Unicode box drawing chars as non-ascii
" TODO: Look into fzf source code for all other possible Unicode chars
let w:ignore_non_ascii_chars = '─│╭╮╰╯▌' .. get(w:, 'ignore_non_ascii_chars', '')
" Update after changes
call HighlightNonASCIIChars()
