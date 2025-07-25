#!/bin/sh

if [ 1 -lt "$(xrandr -q | grep -c " connected")" ]; then
	# scale second monitor to 3200x1800 and put to the left
	xrandr --output eDP1 --auto --pos 0x0 --primary \
	       --output DP1 --auto --scale-from 3200x1800 --pos 3200x0 \
	       --fb 6400x1800
	feh --bg-scale --no-fehbg "$HOME"/media/pics/wallpapers/wallpaper
	killall -q polybar
	while pgrep -x polybar >/dev/null; do sleep 1; done
else
	xrandr --output eDP1 --auto --output DP1 --off
fi

"${XDG_CONFIG_HOME:-$HOME/.config}/polybar/launch.sh" &
