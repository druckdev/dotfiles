#!/bin/sh

# if there is no running instance
if ! pgrep -ax polybar >/dev/null 2>&1; then
	# launch Polybar on every monitor
	# https://github.com/polybar/polybar/issues/763
	primary="$(xrandr -q | grep primary | cut -d' ' -f1)"
	for m in $(polybar --list-monitors | cut -d':' -f1); do
		export TRAY_POS=none
		[ "$m" != "$primary" ] || export TRAY_POS=right
		export MONITOR="$m"
		polybar --reload -c "${XDG_CONFIG_HOME:-$HOME/.config}/polybar/config" main &
	done

	echo "Polybar launched..."
else
	polybar-msg cmd restart
fi
