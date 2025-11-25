" Shorter lines. Subject should be max 50 and body max 72
setlocal colorcolumn+=51
setlocal textwidth=72
" Spell checking always enabled
setlocal spell spelllang=en
" Disable C-indentation as it messes up formatting of paragraphs containing
" parentheses
setlocal nocindent

" Disable gutentags as it seems to regenerate the entire tags file when editing
" git-commits...
let g:gutentags_enabled = 0

" Red highlight of overflow should come at 60 chars, not 50.
" TODO: highlight chars >50, but <60 in yellow, see
"       /usr/share/nvim/runtime/syntax/gitcommit.vim
" (see a376ff7b784c ("hooks:commit-msg: Relax subject length limit to 60"))
"let g:gitcommit_summary_length = 60

" When aborting a commit I usually use :cq which I can't when committing through
" fugitive. Abbreviate it to something that works.
cabbrev <buffer> cq %d <Bar> x

" Fold file listings (staged, unstaged, untracked, ...) and diff
setlocal foldmethod=syntax

" Unfold staged files and diff. inspired by:
" https://vi.stackexchange.com/questions/4050/how-to-search-for-pattern-in-certain-syntax-regions/27008#27008
if has("patch-8.2.0915") || has("nvim-0.7.0")

function s:open_fold(group, content)
	" Find line containing `content` that is highlighted with `group`
	let l:line_nr = search(a:content, "n", 0, 0, { ->
		\ synstack('.', col('.'))
		\ ->map('synIDattr(v:val, "name")')
		\ ->match(a:group) < 0 })
	if l:line_nr <= 0
		return
	endif
	execute l:line_nr->string() .. "foldopen"
endfunction

call s:open_fold("gitcommitSelected", "Changes to be committed:")
call s:open_fold("gitcommitDiff", "diff --")

endif " has("patch-8.2.0915") || has("nvim-0.7.0")
