" NOTE: The global man ftplugin enables wrapping which I want off (see below),
"       which is why this needs to be in after/.

" Spelling makes no sense in manpages
setlocal nospell

" man(1) will assume it can use the full width of the terminal when
" hard-wrapping the lines. When signcolumn is enabled the width is one cell
" smaller and thus, lines that have a character in the last column will be
" wrapped by vim (i.e. almost all of them).
setlocal signcolumn=no

" Make scrolling easier/more reactive through a big scrolloff
setlocal scrolloff=999

" Position cursor in the middle when launching so that scrolling down starts
" immediately
normal M

" ------------------------------------------------------------------------------
" From :h :Man:
"
"     when running `man` from the shell and with that `MANPAGER` [='nvim +Man!']
"     in your environment, `man` will pre-format the manpage using `groff`.
"     Thus, Nvim will inevitably display the manual page as it was passed to it
"     from stdin. One of the caveats of this is that the width will _always_ be
"     hard-wrapped
"
" Since I actually don't like `g:man_hardwrap=0`/`MANPAGER=999` (e.g. scrolling
" can be a mess with very long wrapped lines), the following autocommand is
" meant to reload the manpage through `:edit` after every resize, so that its
" hard-wrapping adjusts to the new size.
"
" This is slightly hacky, but does its job quite well.

augroup man_resized
	" The reload has to be delayed slightly, since with an `edit` directly in
	" the autocmd, the buffer will just be cleared? (TODO)
	" NOTE: One could add a wrapper function that checks for the existence of
	"       already running timers similar to how it's done in the
	"       highlight_current group (see autocommands.vim), but this feels
	"       overkill here.
	au! WinResized <buffer> call timer_start(10, function("s:edit_delayed"))
augroup END

" The function can't be redefined during the reload of the ftplugin (i.e.
" triggered by `edit`), since it is currently executing (i.e. `edit`):
"
"     E127: Cannot redefine function <SNR>94_edit_delayed: It is in use
"
if !exists("*s:edit_delayed")
	function s:edit_delayed(timer_id)
		edit
	endfunction
endif

" When wrapping is turned on, shrinking the window will momentarily rewrap the
" lines, messing up the whole buffer. Since this is distracting, turn it off.
setlocal nowrap
" ------------------------------------------------------------------------------
