# TODO: Why do we need this here again? What overrides it after being executed
#       in 20-completion.zsh?
# Colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Preview files and folders
# NOTE: Find out more about current context with <c-x>h
(( $+commands[bat] )) && file_prev_cmd="bat --color=always" || file_prev_cmd=cat
(( $+commands[tree] )) && dir_prev_cmd="tree -C -L 3" || dir_prev_cmd=ls
read -r -d '' preview_cmd <<EOT
	[[ -d \$realpath ]] && $dir_prev_cmd \$realpath || $file_prev_cmd \$realpath
EOT
# Programs for which file and folder preview should be activated
file_commands=(ls-show-hidden cd ln cp mv nvim rsync git-add '*--')
zstyle ":fzf-tab:complete:(${(j:|:)file_commands}):*" fzf-preview "$preview_cmd"
# Disable preview for options again (completion that starts with '-')
zstyle ":fzf-tab:complete:(${(j:|:)file_commands}):options" fzf-preview
unset {file,dir}_prev_cmd preview_cmd file_commands

# Preview variables
# TODO: Only works with exported values as this is executed in a subshell
#       One could execute this beforehand:
#
#       eval "$(typeset + | awk '{print "export " $NF}')"
zstyle ':fzf-tab:complete:-parameter-:*' fzf-preview 'typeset -p1 "$word"'

# Move down after selecting and yank with ctrl-y
zstyle ':fzf-tab:complete:*' fzf-bindings 'ctrl-space:toggle+down' 'ctrl-y:yank'

# Switch completion groups with the keys `.` & `,`
zstyle ':fzf-tab:*' switch-group ',' '.'

# Remove color preview symbol
zstyle ':fzf-tab:*' prefix ''

# vim: ft=zsh
