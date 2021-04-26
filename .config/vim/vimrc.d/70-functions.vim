" Functions ####################################################################
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
		checktime
	endfunc
	execute timer_start(1000, 'CheckTime', {'repeat': -1})
endif
