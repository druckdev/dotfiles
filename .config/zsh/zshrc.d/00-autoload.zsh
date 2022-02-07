autoload -U select-word-style && select-word-style bash

autoload edit-command-line; zle -N edit-command-line

autoload -U add-zsh-hook

(( ! $+aliases[run-help] )) || unalias run-help
autoload -Uz run-help run-help-git zmv

# Load autoloadable functions
if [[ -d "$ZDOTDIR/autoload" ]]; then
	# Include all subdirectories
	for d in "$ZDOTDIR/autoload/"*(/N); do
		fpath=("$d" $fpath)
		autoload -Uz -- "" "$d"/[^_.]*(.xN:t)
	done

	fpath=("$ZDOTDIR/autoload" $fpath)
	autoload -Uz -- "" "${fpath[1]}"/[^_.]*(.xN:t)
fi
