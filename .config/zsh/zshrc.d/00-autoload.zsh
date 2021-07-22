autoload -U select-word-style && select-word-style bash

autoload edit-command-line; zle -N edit-command-line

(( ! $+aliases[run-help] )) || unalias run-help
autoload -Uz run-help run-help-git zmv

# Load autoloadable functions
if [[ -d "$ZDOTDIR/autoload" ]]; then
	fpath=("$ZDOTDIR/autoload" $fpath)
	autoload -Uz -- "" "${fpath[1]}"/[^_.]*(.xN:t)
fi
