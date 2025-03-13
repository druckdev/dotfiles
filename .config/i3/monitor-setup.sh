#!/bin/sh

# Keep a little distance between the two as the gaussian blur will otherwise
# spill over an adjacent window. (Test: Open an white window on one monitor and
# a terminal or window with blurred transparent background on the other)
xrandr --output DP-0 --primary --mode 3440x1440 --rate 144.00 # --pos 0x0 --output HDMI-0 --mode 1920x1080 --rate 60.00 --scale-from 2560x1440 --pos 3640x0
"${XDG_CONFIG_HOME:-$HOME/.config}/polybar/launch.sh" &
exit

if [ 1 -lt "$(xrandr -q | grep " connected" | wc -l)" ]; then
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
