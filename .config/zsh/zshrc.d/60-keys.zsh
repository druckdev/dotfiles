## Author:  druckdev
## Created: 2019-04-17

# Vim bindings
bindkey -v

# Text object selection
# Copied and slightly modified from:
# https://github.com/softmoth/zsh-vim-mode/blob/abef0c0c03506009b56bb94260f846163c4f287a/zsh-vim-mode.plugin.zsh#L214-#L228
autoload -U select-bracketed select-quoted
zle -N select-bracketed
zle -N select-quoted
for m in visual viopp; do
	for c in {a,i}{\(,\),\[,\],\{,\},\<,\>,b,B}; do
		bindkey -M "$m" "$c" select-bracketed
	done
	for c in {a,i}{\',\",\`}; do
		bindkey -M "$m" "$c" select-quoted
	done
done

# Decrease delay when switching into NORMAL mode.
# A timeout is still necessary as otherwise multi character bindings (for
# example in vicmd) do not work.
export KEYTIMEOUT=20

function zle-line-init zle-keymap-select {
	# Switch cursor style depending on mode
	case $KEYMAP in
		vicmd) echo -ne "\e[1 q";; # block
		viins|main) echo -ne "\e[5 q";; # beam
	esac

	# Make sure that the terminal is in application mode when zle is active,
	# since only then values from $terminfo are valid
	! (( $+terminfo[smkx] )) || echoti smkx
}
zle -N zle-line-init
zle -N zle-keymap-select

function zle-line-finish {
	# See above (echoti smkx)
	! (( $+terminfo[rmkx] )) || echoti rmkx
}
zle -N zle-line-finish

bindkey '^H' run-help
bindkey '^E' edit-command-line

## Navigation
bindkey '^[[Z' reverse-menu-complete         # shift-tab
bindkey '^Q' push-input                      # ctrl-Q
bindkey '\e[H' beginning-of-line             # home
bindkey "$terminfo[khome]" beginning-of-line # home
bindkey '\e[F' end-of-line                   # end
bindkey "$terminfo[kend]" end-of-line        # end
bindkey -v '^?' backward-delete-char         # normal delete not vim-bac...
bindkey '^[[P' delete-char                   # delete
bindkey '^[[3~' delete-char                  # delete
bindkey '^[[1;5D' backward-word              # ctrl-left
bindkey '^[[1;5C' forward-word               # ctrl-right
bindkey '^H' backward-kill-word              # ctrl-backspace
bindkey '^[[3;5~' kill-word                  # ctrl-delete
bindkey "$terminfo[kmous]" kill-word         # ctrl-delete

# Open file in EDITOR selected with fzf
function edit-fuzzy-file {
	local fzf_fallback="find . -type f"
	local -a fzf_args=(--height "40%" --reverse)

	file="$(eval ${FZF_DEFAULT_COMMAND:-$fzf_fallback} | fzf "$fzf_args[@]")"
	[[ -z $file ]] || $EDITOR "$file"

	# Fix prompt
	zle redisplay
}
zle -N edit-fuzzy-file
# Simulate <leader>f from vim config
bindkey -M vicmd " f" edit-fuzzy-file

# Modified version (end with a trailing slash) of:
# https://github.com/majutsushi/etc/blob/1d8a5aa28/zsh/zsh/func/rationalize-dots
function rationalize_dots {
	# Rationalize dots at BOL or after a space or slash.
	if [[ "$LBUFFER" =~ "(^|[ /])\.\./$" ]]; then
		LBUFFER+=../
	elif [[ "$LBUFFER" =~ "(^|[ /])\.$" ]]; then
		LBUFFER+=./
	else
		LBUFFER+=.
		return
	fi

	# Print currently typed path as absolute path with "collapsed"/reversed
	# filename expansion.
	zle -M "${(D)${(z)LBUFFER}[-1]:a}"
}
zle -N rationalize_dots
bindkey . rationalize_dots

function cmd-on-enter {
	zle -M "$CMD_ON_ENTER"
	if [[ -z $BUFFER ]]; then
		# Overwrite BUFFER and default to ll
		BUFFER="${CMD_ON_ENTER:=ll}"

		# Cycle through ll and git status
		case "$CMD_ON_ENTER" in
			ll)
				! git rev-parse &>/dev/null || CMD_ON_ENTER='gs';;
			gs)
				CMD_ON_ENTER='ll';;
		esac
	else
		# Reset if other command is executed
		CMD_ON_ENTER=ll
	fi
	zle accept-line
}
zle -N cmd-on-enter
bindkey "^M" cmd-on-enter
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(cmd-on-enter)

## History
# Ctrl-Up
bindkey '^[[1;5A' fzf-history-widget
# Ctrl-K in normal mode
bindkey -M vicmd '^K' fzf-history-widget

# Fuzzy finder bindings:
# ^T fzf-file-widget
# \ec (Alt-C) fzf-cd-widget
# ^R fzf-history-widget
comp-source "$ZDOTDIR/plugins/fzf/shell/key-bindings.zsh"
