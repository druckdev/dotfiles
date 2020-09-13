#!/bin/sh

if [ "$1" = "-k" ];  then
	killall -q compton
elif ! pgrep -ax compton >/dev/null 2>&1; then
	compton --config "${XDG_CONFIG_HOME:-$HOME/.config}/compton/compton.conf" -b
fi
