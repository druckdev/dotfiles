autoload -U select-word-style && select-word-style bash

autoload edit-command-line; zle -N edit-command-line

autoload -U add-zsh-hook

(( ! $+aliases[run-help] )) || unalias run-help
autoload -Uz run-help run-help-git zmv

# Load autoloadable functions
if [[ -d "$ZDOTDIR/autoload" ]]; then
	local d

	# Include all wrapper scripts if their wrapped command exists
	for d in "$ZDOTDIR/autoload/"**/wrapper(/N); do
		fpath=("$d" $fpath)
		for f in "$d"/[^_.]*(xN^/:t); do
			(( $+commands[$f] )) || continue
			autoload -Uz -- "$f"
		done
	done

	# Include all other subdirectories
	for d in "$ZDOTDIR/autoload/"**(/N); do
		# EXTENDED_GLOB is not yet set, so we have to exclude manually
		[[ ${d:t} != wrapper ]] || continue

		fpath=("$d" $fpath)
		autoload -Uz -- "" "$d"/[^_.]*(xN^/:t)
	done

	fpath=("$ZDOTDIR/autoload" $fpath)
	autoload -Uz -- "" "${fpath[1]}"/[^_.]*(xN^/:t)
fi
