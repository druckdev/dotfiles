#!/bin/bash

# The separation and recursion is sadly necessary since reload is apparently
# executed in a subshell and thus using an environment variable does not work

dn="reload(\"$0\" -)"
up="reload(\"$0\" +)"
FZF_ARGS=(
	--reverse
	--no-sort
	--no-info
	--phony
	--prompt=
	--bind="ctrl-j:$dn,down:$dn,ctrl-k:$up,up:$up,enter:abort"
)

if [[ $# -eq 0 ]]; then
	# Frontend

	# Create temporary file for the counter that should be removed when exiting.
	export FZF_CAL_TMP="$(mktemp)"
	trap "rm -f $FZF_CAL_TMP" EXIT
	echo 0 > "$FZF_CAL_TMP"

	# Call fzf
	cal -wm | fzf "${FZF_ARGS[@]}"
	exit 0
else
	# Backend

	# + Add to counter, going back in time
	# - Subtract from counter, going forward in time
	# = Print current month without modifying the counter
	[[ $1 = "+" || $1 = "-" || $1 = "=" ]] || exit 1
	[[ -n $FZF_CAL_TMP ]] || exit 1

	counter=$(cat "$FZF_CAL_TMP")
	if [[ $1 != "=" ]]; then
		# Increment or decrement counter
		: $((counter$1$1))
		echo $counter >"$FZF_CAL_TMP"
	fi

	# Print calendar
	cal -wm $(date +"%m %Y" -d "$counter months ago")
fi