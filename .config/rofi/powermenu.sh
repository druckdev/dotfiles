#!/usr/bin/env bash
# Inspired by:
# https://github.com/cramermarius/rofi-menus/blob/master/scripts/powermenu.sh

# Make this script work on systems with and without full systemd (e.g. elogind)
if command -v systemctl &>/dev/null; then
	controller=systemctl
else
	controller=loginctl
fi

# entries with associated commands
declare -A entries
entries=(
	[lock]="xset s activate"
	[logout]="i3-msg exit"
	[reboot]="$controller reboot"
	[shutdown]="$controller poweroff"
	[suspend]="$controller suspend"
	["suspend (scheduled)"]="scheduled_suspend"
)

declare -a rofi_args
rofi_args=(
	-no-config
	-theme /usr/share/rofi/themes/android_notification.rasi
	-theme-str "#listview { lines: ${#entries[@]}; fixed-height: false; }"
	-theme-str "#window { width: 12%; }"
	-location 3
	-yoffset 32
	-dmenu
	-no-case-sensitive
	-p # -p at end for dynamic prompt
)

scheduled_suspend() {
	declare -i min=0
	min=$(rofi "${rofi_args[@]}" "minutes")

	# make sure the input was a valid number
	# side effect: 0 minutes is not possible
	[[ "$min" -ne 0 ]] || exit 1

	notify-send "suspend in" "$min minutes"
	sleep $((min*60)) && ${entries[suspend]}
}

# Choose option over rofi
# Note: bash does not keep the order of the keys thus they get sorted
chosen="$(
	printf '%s\n' "${!entries[@]}" \
	| sort \
	| rofi "${rofi_args[@]}" "power"
)"
# exit if nothing was selected
[[ -n "$chosen" ]] || exit 1
# handle scheduled suspend different
[[ "$chosen" != "suspend (scheduled)" ]] || { ${entries[$chosen]}; exit $?; }

# Confirm choice
yesNo="$(rofi "${rofi_args[@]}" "Confirm to ${chosen}" <<<$'no\nyes')"

# Exit if "No"
[[ "$yesNo" == "yes" ]] || exit 1

# Execute
${entries[$chosen]}
