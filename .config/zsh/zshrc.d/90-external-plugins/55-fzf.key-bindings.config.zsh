# Overwrite fzf's Alt-C binding to be "in-prompt"

# Modified version of
# https://github.com/junegunn/fzf/blame/f864f8b5f7ab/shell/key-bindings.zsh#L81-L99
# that changes the directory "in-prompt", meaning that the `cd` command is
# executed in the background with a prompt redraw instead of via `$BUFFER` and
# `accept-line`. This behavior is inspired by cd-{forward,backward} written by
# romkatv (see keys.zsh).
fzf-cd-inprompt-widget() {
	setopt localoptions pipefail no_aliases 2>/dev/null
	local dir="$(
		FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
		FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
		FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty)"
	if [[ -z "$dir" ]]; then
		zle redisplay
		return 0
	fi
	# --- modifications start here ---
	pushd -q "$dir"
	redraw-prompt
}
zle -N fzf-cd-inprompt-widget
bindkey -M vicmd '\ec' fzf-cd-inprompt-widget
bindkey -M viins '\ec' fzf-cd-inprompt-widget
