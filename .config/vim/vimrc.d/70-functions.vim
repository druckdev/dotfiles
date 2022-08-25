" Functions """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle spell language between German and English
function! CycleSpellLang()
	if (&spelllang == 'en')
		set spelllang=de
	else
		set spelllang=en
	endif
endfunction

" Check time every second to read file changes.
if (exists('+autoread') && &autoread)
	function! CheckTime(timer)
		" NOTE: silent the checktime call as it is an invalid command in the
		" command line window
		silent! checktime
	endfunc
	call timer_start(1000, 'CheckTime', {'repeat': -1})
endif
