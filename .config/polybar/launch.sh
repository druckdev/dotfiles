#!/bin/bash

XDG_CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
BASE_DIR="$XDG_CONF/polybar"

declare -A module_flags
module_flags=(
	[battery]="$BASE_DIR/scripts/battery.sh"
	[bluetooth]="$BASE_DIR/scripts/bluetooth.sh"
	[bluetooth_click_left]="$BASE/scripts/bluetooth.sh --toggle &"
	[media]="$BASE_DIR/scripts/media.sh"
	[powermenu]="%{A1:$XDG_CONF/rofi/powermenu.sh &:}%{T2}...%{T-}%{A}"
	[vpn]="$BASE_DIR/scripts/vpn.sh"
	[vpn_click_left]="$BASE_DIR/scripts/pub_ipv4.sh &"
)
for module in "${!module_flags[@]}"; do
	export POLYBAR_${module^^}="${module_flags[$module]}"
done

# if there is no running instance
if ! pgrep -ax polybar >/dev/null 2>&1; then
	# launch Polybar on every monitor
	# https://github.com/polybar/polybar/issues/763
	primary="$(xrandr -q | grep primary | cut -d' ' -f1)"
	for m in $(polybar --list-monitors | cut -d':' -f1); do
		export TRAY_POS=none
		[[ "$m" != "$primary" ]] || export TRAY_POS=right
		export MONITOR="$m"
		polybar --reload -c "$BASE_DIR/config" main &
	done

	echo "Polybar launched..."
else
	polybar-msg cmd restart
fi
