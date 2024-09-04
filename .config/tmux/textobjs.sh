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

# ignore any args
set --

case "$motion" in
	w)
		copy_x="$(get_var copy_cursor_x)"
		copy_line="$(get_var copy_cursor_line)"

		# Do nothing if the cursor sits on a space
		# TODO: Do the same for other non-word characters
		# NOTE: Using grep here, as cut does not support UTF-8
		char_curr="$(printf %s "$copy_line" | grep -Po "^.{$copy_x}\\K.")"
		[ "$char_curr" != " " ] || return 0

		copy_line_post="$(printf %s "$copy_line" | grep -Po "^.{$copy_x}\\K.*")"
		copy_line_pre="$(printf %s "$copy_line" | grep -Po "^..{$copy_x}")"
		copy_word="$(get_var copy_cursor_word)"

		# send "boe"
		if [ "${copy_line_post#"$copy_word"}" = "$copy_line_post" ];
		then
			# not on beginning of word
			set -- "$@" send -X previous-word \;
			set -- "$@" send -X other-end \;
		fi
		if [ "${copy_line_pre%"$copy_word"}" = "$copy_line_pre" ];
		then
			# not on end of word
			set -- "$@" send -X next-word-end \;
		fi
		;;
	W)
		copy_x="$(get_var copy_cursor_x)"
		copy_line="$(get_var copy_cursor_line)"

		# Do nothing if the cursor sits on the space
		char_curr="$(printf %s "$copy_line" | grep -Po "^.{$copy_x}\\K.")"
		[ "$char_curr" != " " ] || return 0

		char_pre="$(printf %s "$copy_line" | grep -Po "^.{$((copy_x - 1))}\\K.")"
		char_post="$(printf %s "$copy_line" | grep -Po "^..{$copy_x}\\K.")"

		# default to a space if the cursor is at the beginning or end of
		# the line
		: "${char_pre:= }"
		: "${char_post:= }"

		# send "BoE"
		if [ "$char_pre" != " " ]; then
			# not on beginning of WORD
			set -- "$@" send -X previous-space \;
			set -- "$@" send -X other-end \;
		fi
		if [ "$char_post" != " " ]; then
			# not on end of WORD
			set -- "$@" send -X next-space-end \;
		fi
		;;
	p)
		# send "{j0o}k$"

		set -- "$@" send -X previous-paragraph \;

		scroll_pos="$(get_var scroll_position)"
		hist_size="$(get_var history_size)"
		cursor_y="$(get_var copy_cursor_y)"
		# don't move down if we're at the very first paragraph
		if [ "$scroll_pos" -lt "$hist_size" ] || [ "$cursor_y" -gt 0 ]
		then
			set -- "$@" send -X cursor-down \;
		fi

		set -- "$@" send -X start-of-line \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X next-paragraph \;

		scroll_pos="$(get_var scroll_position)"
		cursor_y="$(get_var copy_cursor_y)"
		pane_height="$(get_var pane_height)"
		: "$((pane_height -= 1))"
		# don't move up if we're at the very last paragraph
		if [ "$scroll_pos" -gt 0 ] || [ "$cursor_y" -lt "$pane_height" ]
		then
			set -- "$@" send -X cursor-up \;
		fi

		set -- "$@" send -X end-of-line \;
		;;
	# TODO: All following break when the cursor sits on the start or end
	\")
		set -- "$@" send -X jump-to-backward '"' \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward '"' \;
		;;
	\')
		set -- "$@" send -X jump-to-backward "'" \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward "'" \;
		;;
	\`)
		set -- "$@" send -X jump-to-backward '`' \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward '`' \;
		;;
	'[|]')
		set -- "$@" send -X jump-to-backward '[' \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward ']' \;
		;;
	'b|(|)')
		set -- "$@" send -X jump-to-backward '(' \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward ')' \;
		;;
	'<|>')
		set -- "$@" send -X jump-to-backward '<' \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward '>' \;
		;;
	'B|{|}')
		# TODO: make this work over multiple lines
		set -- "$@" send -X jump-to-backward '{' \;
		set -- "$@" send -X other-end \;
		set -- "$@" send -X jump-to-forward '}' \;
		;;
esac

[ $# -eq 0 ] || tmux "$@"
