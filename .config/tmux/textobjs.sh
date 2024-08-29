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

case "$motion" in
	w)
		copy_x="$(get_var copy_cursor_x)"
		: "$((copy_x += 1))"
		copy_line="$(get_var copy_cursor_line)"

		# Do nothing if the cursor sits on a space
		# TODO: Do the same for other non-word characters
		char_curr="$(printf %s "$copy_line" | cut -c$((copy_x + 1)))"
		[ "$char_curr" != " " ] || return 0

		copy_line_post="$(printf %s "$copy_line" | cut -c"${copy_x}"-)"
		copy_line_pre="$(printf %s "$copy_line" | cut -c-"${copy_x}")"
		copy_word="$(get_var copy_cursor_word)"

		# send "boe"
		if [ "${copy_line_post#"$copy_word"}" = "$copy_line_post" ];
		then
			# not on beginning of word
			tmux send -X previous-word
			tmux send -X other-end
		fi
		if [ "${copy_line_pre%"$copy_word"}" = "$copy_line_pre" ];
		then
			# not on end of word
			tmux send -X next-word-end
		fi
		;;
	W)
		copy_x="$(get_var copy_cursor_x)"
		copy_line="$(get_var copy_cursor_line)"

		# Do nothing if the cursor sits on the space
		char_curr="$(printf %s "$copy_line" | cut -c$((copy_x + 1)))"
		[ "$char_curr" != " " ] || return 0

		# NOTE: cut will print an error on index 0
		char_pre="$(printf %s "$copy_line" | cut -c"$copy_x" 2>/dev/null)"
		char_post="$(printf %s "$copy_line" | cut -c$((copy_x + 2)))"

		# default to a space if the cursor is at the beginning or end of
		# the line
		: "${char_pre:= }"
		: "${char_post:= }"

		# send "BoE"
		if [ "$char_pre" != " " ]; then
			# not on beginning of WORD
			tmux send -X previous-space
			tmux send -X other-end
		fi
		if [ "$char_post" != " " ]; then
			# not on end of WORD
			tmux send -X next-space-end
		fi
		;;
	p)
		# send "{j0o}k$"

		tmux send -X previous-paragraph

		scroll_pos="$(get_var scroll_position)"
		hist_size="$(get_var history_size)"
		cursor_y="$(get_var copy_cursor_y)"
		# don't move down if we're at the very first paragraph
		if [ "$scroll_pos" -lt "$hist_size" ] || [ "$cursor_y" -gt 0 ]
		then
			tmux send -X cursor-down
		fi

		tmux send -X start-of-line
		tmux send -X other-end
		tmux send -X next-paragraph

		scroll_pos="$(get_var scroll_position)"
		cursor_y="$(get_var copy_cursor_y)"
		pane_height="$(get_var pane_height)"
		: "$((pane_height -= 1))"
		# don't move up if we're at the very last paragraph
		if [ "$scroll_pos" -gt 0 ] || [ "$cursor_y" -lt "$pane_height" ]
		then
			tmux send -X cursor-up
		fi

		tmux send -X end-of-line
		;;
	# TODO: These two fail when the cursor sits on the quote
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
