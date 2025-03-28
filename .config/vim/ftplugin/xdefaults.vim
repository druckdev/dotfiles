" SPDX-License-Identifier: MIT
" Copyright (c) 2020 Julian Prein

" Update resource database automatically.
autocmd BufWritePost * !xrdb %
