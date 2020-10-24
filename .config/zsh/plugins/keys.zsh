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

# no delay when switching into NORMAL
export KEYTIMEOUT=1

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

bindkey '^[h' run-help

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

function ls-on-enter {
	# Execute `ls` when enter is pressed without a command entered.
	[[ -n "$BUFFER" ]] || BUFFER=ls
	zle accept-line

	# See fzf-hist below
	FZF_HIST_WENT_UP=
}
zle -N ls-on-enter
bindkey "^M" ls-on-enter
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(ls-on-enter)

# "Scroll" through history if buffer was empty but use it as query for fzf over
# command line history if not (similar to substring-search but with fzf)
function fzf-hist-up {
	if [[ -z "$BUFFER" || "$FZF_HIST_WENT_UP" -eq 1 ]]; then
		zle up-line-or-history
		FZF_HIST_WENT_UP=1
	else
		# Will take BUFFER as query
		fzf-history-widget
	fi
}
function fzf-hist-down {
	zle down-line-or-history
	[[ -n "$BUFFER" ]] || FZF_HIST_WENT_UP=
}
zle -N fzf-hist-up
zle -N fzf-hist-down

## History
# Up
bindkey '^[[A' fzf-hist-up
bindkey "$terminfo[kcuu1]" fzf-hist-up
# Ctrl-Up
bindkey '^[[1;5A' fzf-history-widget
# Down
bindkey '^[[B' fzf-hist-down
bindkey "$terminfo[kcud1]" fzf-hist-down
# Ctrl-K
bindkey '^K' fzf-hist-up
# Ctrl-K in normal mode
bindkey -M vicmd '^K' fzf-history-widget
# Ctrl-J
bindkey '^J' fzf-hist-down

# Fuzzy finder bindings:
# ^T fzf-file-widget
# \ec (Alt-C) fzf-cd-widget
# ^R fzf-history-widget
comp-source "$ZSH_CONF/fzf/shell/key-bindings.zsh"
