#!/bin/sh

# if there is no running instance
if ! pgrep -ax polybar >/dev/null 2>&1; then
	# launch Polybar on every monitor
	# https://github.com/polybar/polybar/issues/763#issuecomment-392960721
	for m in $(polybar --list-monitors | cut -d':' -f1); do
		MONITOR=$m polybar --reload -c "$HOME/.config/polybar/config" main &
	done

	echo "Polybar launched..."
fi
