" SPDX-License-Identifier: MIT
" Copyright (c) 2022 Julian Prein

" Reuse git-commit textwidths for subject (minus the `# ` markdown
" header-prefix) and body. This way the note (but especially the subject) should
" be usable as a commit message.
setlocal colorcolumn+=53
setlocal textwidth=72
" Spell checking always enabled
setlocal spell spelllang=en
" Automatic formatting
setlocal formatoptions+=a
