" Functions ####################################################################
" Toggle spell language between German and English
function! CycleSpellLang()
	if (&spelllang == 'en')
		set spelllang=de
	else
		set spelllang=en
	endif
endfunction
