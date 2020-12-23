" Commands #####################################################################
command! DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis
	\ | wincmd p | diffthis
