let w:ignore_non_ascii_chars = get(w:, 'ignore_non_ascii_chars', '')

" Do not highlight Unicode chars used for the TUI
" Unicode "Box Drawing" block
let w:ignore_non_ascii_chars ..= '\u2500-\u257f'
" Unicode "Block Elements" block
let w:ignore_non_ascii_chars ..= '\u2580-\u259f'
" Unicode "Block elements" subblock of the "Symbols for Legacy Computing" block
" (i.e. 1/8th block symbols)
let w:ignore_non_ascii_chars ..= '\U0001fb70-\U0001fb89'
" Braille symbols for spinner
let w:ignore_non_ascii_chars ..= '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

" Update after changes
call HighlightNonASCIIChars()
