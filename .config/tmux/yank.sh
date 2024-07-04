#!/bin/sh

# Support repeatable motions when yanking from tmux's copy-mode.
#
# See also the `bind -T copy-mode-vi i ...` binding in tmux.conf
# (83945840b832 ("tmux: Rudimentary vim's text object simulation"))

get_var() {
	tmux display-message -p "#{$1}"
}

command_prompt() {
	tmux command-prompt -k -I "$2" -p "$1" 'display-message -p "%%"'
}

mode="$(get_var pane_mode)"
if [ "$mode" != copy-mode ]; then
	>&2 printf "%s: Not in copy mode\n" "$0"
	exit 1
fi

# Just yank if we have a selection already
selection_present="$(get_var selection_present)"
if [ "$selection_present" -eq 1 ]; then
	tmux send -X copy-pipe
	exit 0
fi

# get motion
motion="$(command_prompt "(operator-pending)")"

# accumulate repeat number
# NOTE: -N unfortunately does not work since the first non-numeric key press is
#       lost then (TODO: is it really?)
while printf "%s" "$motion" | grep -q '^[0-9]$'; do
	repeat="$repeat$motion"
	motion="$(command_prompt "(operator-pending-repeat)" "$repeat")"
done
# default to 1 if no repeat was specified
: "${repeat:=1}"

# abort on Escape
[ "$motion" != "Escape" ] || exit 0

# choose between character or line-wise selection
case "$motion" in
	y)
		repeat="$((repeat - 1))"
		motion="j"
		tmux send -X select-line;;
	j|k)
		tmux send -X select-line;;
	*)
		tmux send -X begin-selection;;
esac

# move and yank
[ "$repeat" -eq 0 ] || tmux send -N "$repeat" "$motion"
tmux send -X copy-pipe
