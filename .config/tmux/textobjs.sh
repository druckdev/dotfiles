#!/bin/sh

# Support vim's text objects in tmux's copy-mode.

get_var() {
	tmux display-message -p "#{$1}"
}

command_prompt() {
	tmux command-prompt -k -I "$2" -p "$1" 'display-message -p "%%"'
}

copy_exec() {
	num_cmds=$#

	# since POSIX shell does not include arrays I use `set` here. This keeps
	# the initial arguments though (for now), since I cannot copy $@ (as an
	# array) to a different variable to have a clean $@ in the first
	# iteration.
	for arg in "$@"; do
		set -- "$@" \; send -X "$arg"
	done

	# get rid of initial arguments + first semicolon
	shift $((num_cmds + 1))

	tmux "$@"
}

mode="$(get_var pane_mode)"
if [ "$mode" != copy-mode ]; then
	>&2 printf "%s: Not in copy mode\n" "$0"
	exit 1
fi

# cancel copy-mode when not in 'visual' mode (i.e. selection is present)
selection_present="$(get_var selection_present)"
if [ "$selection_present" -eq 0 ]; then
	copy_exec cancel
	exit 0
fi

# get motion
motion="$(command_prompt "(operator-pending)")"

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
			copy_exec previous-word other-end
		fi
		if [ "${copy_line_pre%"$copy_word"}" = "$copy_line_pre" ];
		then
			# not on end of word
			copy_exec next-word-end
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
			copy_exec previous-space other-end
		fi
		if [ "$char_post" != " " ]; then
			# not on end of WORD
			copy_exec next-space-end
		fi
		;;
	p)
		# send "{j0o}k$"

		copy_exec previous-paragraph

		scroll_pos="$(get_var scroll_position)"
		hist_size="$(get_var history_size)"
		cursor_y="$(get_var copy_cursor_y)"
		# don't move down if we're at the very first paragraph
		if [ "$scroll_pos" -lt "$hist_size" ] || [ "$cursor_y" -gt 0 ]
		then
			copy_exec cursor-down
		fi

		copy_exec start-of-line other-end next-paragraph

		scroll_pos="$(get_var scroll_position)"
		cursor_y="$(get_var copy_cursor_y)"
		pane_height="$(get_var pane_height)"
		: "$((pane_height -= 1))"
		# don't move up if we're at the very last paragraph
		if [ "$scroll_pos" -gt 0 ] || [ "$cursor_y" -lt "$pane_height" ]
		then
			copy_exec cursor-up
		fi

		copy_exec end-of-line
		;;
	# TODO: All following break when the cursor sits on the start or end
	\")
		copy_exec jump-to-backward '"'
		copy_exec other-end
		copy_exec jump-to-forward '"'
		;;
	\')
		copy_exec jump-to-backward "'"
		copy_exec other-end
		copy_exec jump-to-forward "'"
		;;
	\`)
		copy_exec jump-to-backward '`'
		copy_exec other-end
		copy_exec jump-to-forward '`'
		;;
	'[|]')
		copy_exec jump-to-backward '['
		copy_exec other-end
		copy_exec jump-to-forward ']'
		;;
	'b|(|)')
		copy_exec jump-to-backward '('
		copy_exec other-end
		copy_exec jump-to-forward ')'
		;;
	'<|>')
		copy_exec jump-to-backward '<'
		copy_exec other-end
		copy_exec jump-to-forward '>'
		;;
	'B|{|}')
		# TODO: make this work over multiple lines
		copy_exec jump-to-backward '{'
		copy_exec other-end
		copy_exec jump-to-forward '}'
		;;
esac
