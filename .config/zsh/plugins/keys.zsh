## Author:  druckdev
## Created: 2019-04-17

## Setup keybindings
bindkey -v
# no delay when switching into NORMAL
export KEYTIMEOUT=1

function zle-line-init zle-keymap-select {
	# Switch cursor style depending on mode
	case $KEYMAP in
		vicmd) echo -ne "\e[1 q";; # block
		viins|main) echo -ne "\e[5 q";; # beam
	esac

	# Make sure that the terminal is in application mode when zle is active, since
	# only then values from $terminfo are valid
	echoti smkx
}
zle -N zle-line-init
zle -N zle-keymap-select

# See above (echoti smkx)
function zle-line-finish { echoti rmkx; }
zle -N zle-line-finish

bindkey '^[h' run-help

## Navigation
bindkey '^[[Z' reverse-menu-complete         # shift-tab
bindkey '^K' kill-whole-line                 # ctrl-K
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

## From https://github.com/nicoulaj/dotfiles/blob/1c7dd1b621bc8bae895bafc438562482ea245d7e/.config/zsh/functions/widgets/rationalize-dots
function _expandDots {
	#[[ $LBUFFER = *.. ]] && LBUFFER+=/.. || LBUFFER+=.
	setopt localoptions nonomatch
	local MATCH dir split
	split=(${(z)LBUFFER})
	(( $#split > 1 )) && dir=$split[-1] || dir=$split
	if [[ $LBUFFER =~ '(^|/| | |'$'\n''|\||;|&)\.\.$' ]]; then
		LBUFFER+=/
		zle self-insert
		zle self-insert
		[[ -e $dir ]] && zle -M "${dir:a:h}"
	elif [[ $LBUFFER[-1] == '.' ]]; then
		zle self-insert
		[[ -e $dir ]] && zle -M "${dir:a:h}"
	else
		zle self-insert
	fi
}
#autoload _expandDots
zle -N _expandDots
bindkey . _expandDots

function ls-on-enter {
	if [ -z "$BUFFER" ]; then
		echo "ls"
		ls
		echo "\n"
		zle redisplay
	else
		zle accept-line
	fi
	# See fzf-hist below
	FZF_HIST_WENT_UP=
}
zle -N ls-on-enter
bindkey "^M" ls-on-enter
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(ls-on-enter)

# "Scroll" through history if buffer was empty but use it as query for fzf over
# command line history if not (similar to substring-search but with fzf)
function fzf-hist-up {
	if [ -z "$BUFFER" ] || [ "$FZF_HIST_WENT_UP" -eq 1 ]; then
		zle up-line-or-history
		FZF_HIST_WENT_UP=1
	else
		# Will take BUFFER as query
		fzf-history-widget
	fi
}
function fzf-hist-down {
	zle down-line-or-history
	[ -n "$BUFFER" ] || FZF_HIST_WENT_UP=
}
zle -N fzf-hist-up
zle -N fzf-hist-down

## History
# Up
bindkey '^[[A' fzf-hist-up
bindkey "$terminfo[kcuu1]" fzf-hist-up
# Down
bindkey '^[[B' fzf-hist-down
bindkey "$terminfo[kcud1]" fzf-hist-down

# Fuzzy finder bindings:
# ^T fzf-file-widget
# \ec (Alt-C) fzf-cd-widget
# ^R fzf-history-widget
comp-source "$ZSH_CONF/fzf/shell/key-bindings.zsh"
