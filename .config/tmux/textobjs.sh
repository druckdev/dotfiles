#!/bin/sh

# Support vim's text objects in tmux's copy-mode.

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

# cancel copy-mode when not in 'visual' mode (i.e. selection is present)
selection_present="$(get_var selection_present)"
if [ "$selection_present" -eq 0 ]; then
	tmux send -X cancel
	exit 0
fi

# get motion
motion="$(command_prompt "(operator-pending)")"

# TODO: Breaks when on the beginning or end of the object (except paragraphs)
case "$motion" in
	w)
		# send "boe"
		tmux send -X previous-word
		tmux send -X other-end
		tmux send -X next-word-end
		;;
	W)
		# send "BoE"
		tmux send -X previous-space
		tmux send -X other-end
		tmux send -X next-space-end
		;;
	p)
		# send "{j0o}k$"

		tmux send -X previous-paragraph

		scroll_pos="$(get_var scroll_position)"
		hist_size="$(get_var history_size)"
		cursor_y="$(get_var copy_cursor_y)"
		scroll_upper="$(get_var scroll_region_upper)"
		# don't move down if we're at the very first paragraph
		if [ "$scroll_pos" -lt "$hist_size" ] \
			|| [ "$cursor_y" -gt "$scroll_upper" ]
		then
			tmux send -X cursor-down
		fi

		tmux send -X start-of-line
		tmux send -X other-end
		tmux send -X next-paragraph

		scroll_pos="$(get_var scroll_position)"
		cursor_y="$(get_var copy_cursor_y)"
		scroll_lower="$(get_var scroll_region_lower)"
		# don't move up if we're at the very last paragraph
		if [ "$scroll_pos" -gt 0 ] || [ "$cursor_y" -lt "$scroll_lower" ]; then
			tmux send -X cursor-up
		fi

		tmux send -X end-of-line
		;;
	\")
		tmux send -X jump-to-backward '"'
		tmux send -X other-end
		tmux send -X jump-to-forward '"'
		;;
	\')
		tmux send -X jump-to-backward "'"
		tmux send -X other-end
		tmux send -X jump-to-forward "'"
		;;
esac
