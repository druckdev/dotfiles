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
bindkey '^S' vi-pound-insert

# 'Fixed terminal input sequences'
#
# https://www.leonerd.org.uk/hacks/fixterms/
# https://www.leonerd.org.uk/code/libtermkey/

# some shift-<key> combinations should behave like without shift
bindkey -s '^[[32;2u' ' ' # shift-space
bindkey -s '^[[127;2u' '^?' # shift-backspace
bindkey -s '^[[13;2u' '^M' # shift-return

## Navigation
bindkey "$terminfo[kcbt]" reverse-menu-complete  # shift-tab
bindkey "$terminfo[khome]" beginning-of-line     # home
bindkey "$terminfo[kend]" end-of-line            # end
bindkey "$terminfo[kbs]" backward-delete-char    # backspace
bindkey "$terminfo[kdch1]" delete-char           # delete
bindkey '^[[127;5u' backward-kill-word           # ctrl-backspace
bindkey '^W' backward-kill-word                  # ctrl-W
bindkey '^[[1;5D' vi-backward-word               # ctrl-left
bindkey '^[[1;5C' vi-forward-word                # ctrl-right
bindkey '^[[3;5~' vi-kill-word                   # ctrl-delete
bindkey '^Q' push-input                          # ctrl-Q

# cd-{rotate,backward,forward} and redraw-prompt are partially modified copies
# from (Specifically see fn/-z4h-{rotate,redraw-prompt,init-zle}):
# https://github.com/romkatv/zsh4humans/tree/421937693f3772c99c4bdd881ac904e5e9f
function redraw-prompt {
	# hide cursor
	! (( $+terminfo[civis] && $+terminfo[cnorm] )) || [[ ! -t 1 ]] ||
		echoti civis

	local f
	for f in chpwd "${chpwd_functions[@]}" precmd "${precmd_functions[@]}"; do
		[[ "${+functions[$f]}" == 0 ]] || "$f" &>/dev/null || true
	done

	# zsh-syntax-highlighting
	typeset -g _ZSH_HIGHLIGHT_PRIOR_BUFFER=
	typeset -gi _ZSH_HIGHLIGHT_PRIOR_CURSOR=0

	zle .reset-prompt
	zle -R

	# reset cursor
	! (( $+terminfo[cnorm] )) || [[ ! -t 1 ]] || echoti cnorm
}

function cd-rotate() {
	while (( $#dirstack )) && ! pushd -q $1 &>/dev/null; do
		popd -q $1
	done

	redraw-prompt

	(( $#dirstack ))
}

function cd-backward() {
	(( ${cd_cycle:=0} != $#dirstack )) || return
	cd-rotate +1
	(( cd_cycle++ ))
}
zle -N cd-backward

function cd-forward() {
	(( ${cd_cycle:=0} )) || return
	cd-rotate -0
	(( cd_cycle-- ))
}
zle -N cd-forward

# cycle through `dirs` with ^o and ^i similar to the jumplist in vim
bindkey '^O' cd-backward
bindkey '^[[105;5u' cd-forward # ^I

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
		# ../ + . -> ../../
		LBUFFER+=../
	elif [[ "$LBUFFER" =~ "(^|[ /])\.\.$" ]]; then
		# .. + . -> ../../
		# NOTE: This scenario occurs only if backspace or `default_dot` was
		#       used.
		LBUFFER+=/../
	elif [[ "$LBUFFER" =~ "(^|[ /])\.$" ]]; then
		# . + . -> ../
		LBUFFER+=./
	else
		LBUFFER+=.
		return
	fi

	# NOTE: This is a hack to fix the (z) expansion flag if the path is the only
	#       word in LBUFFER, as then [:-1] treats the expansion as a scalar and
	#       returns the last character (i.e. always `/`).
	local lbuffer_words="x $LBUFFER"
	# Print currently typed path as absolute path with "collapsed"/reversed
	# filename expansion.
	zle -M "${(D)${(z)lbuffer_words}[-1]:a}"
}
zle -N rationalize_dots
bindkey . rationalize_dots

# Keep the normal dot self-insert on Ctrl-. (e.g. for typing `../.local`)
function default_dot { LBUFFER+=. }
zle -N default_dot
bindkey '^[[46;5u' default_dot

CMDS_ON_ENTER=(ll gs)
REQUIREMENTS_CMDS_ON_ENTER=(true "git rev-parse")
function cmd-on-enter {
	if [[ -z "${PREBUFFER}${BUFFER}" ]]; then
		# Overwrite BUFFER and default to ll
		BUFFER=" ${CMDS_ON_ENTER[${cmd_on_enter_idx:=1}]}"

		# Cycle through ll and git status
		local idx=$cmd_on_enter_idx
		idx=$((idx < $#CMDS_ON_ENTER ? idx + 1 : 1))
		until
			$REQUIREMENTS_CMDS_ON_ENTER[$idx] &>/dev/null \
			|| [[ $idx = $cmd_on_enter_idx ]]
		do
			idx=$((idx < $#CMDS_ON_ENTER ? idx + 1 : 1))
		done
		cmd_on_enter_idx=$idx
	else
		# Reset if other command is executed
		cmd_on_enter_idx=1
	fi
	zle accept-line
}
zle -N cmd-on-enter
bindkey "^M" cmd-on-enter
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(cmd-on-enter)

# Fuzzy PWD selector of all open shells
function go-shcwd {
	dir="$(shcwd | grep -vFx "$PWD" | fzf)"
	[[ -z $dir ]] || pushd -q "$dir"
	redraw-prompt
}
zle -N go-shcwd
bindkey '^G' go-shcwd

# move one directory up on ^U (mnemonic: 'Up')
function cd-up {
	pushd -q ..
	redraw-prompt
}
zle -N cd-up
bindkey '^U' cd-up

## History
# Ctrl-Up
bindkey '^[[1;5A' fzf-history-widget
# Ctrl-K in normal mode
bindkey -M vicmd '^K' fzf-history-widget

# Fuzzy finder bindings:
# ^T fzf-file-widget
# \ec (Alt-C) fzf-cd-widget
# ^R fzf-history-widget
FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
# Use the fallback default command when ripgrep is not installed but with
# directories instead of files.
FZF_ALT_C_COMMAND="${fzf_default_no_rg/-type f/-type d}"
comp-source "$ZDOTDIR/plugins/fzf/shell/key-bindings.zsh"
