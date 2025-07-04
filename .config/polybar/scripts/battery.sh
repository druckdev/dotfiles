#!/usr/bin/env bash

## config

full=80
low=20

############################

red='%{F#f00}'
green='%{F#0f0}'

bat="$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)" || exit
ac="$(cat /sys/class/power_supply/AC/online 2>/dev/null)"
declare -a ramp
ramp=(          )

# display in red when under $low and no charger is connected
[[ "$bat" -gt "$low" || "$ac" -eq 1 ]] || color="$red"
# display in green when over $full and a charger is connected
[[ "$bat" -lt "$full" || "$ac" -eq 0 ]] || color="$green"

icon_index="$((bat / (${#ramp[@]} - 1)))"
[[ $icon_index -lt ${#ramp[@]} ]] || icon_index=10
icon="${ramp[$icon_index]}"
[[ "$ac" -eq 0 ]] || charge=""

echo "${color}${icon}${charge} ${bat}%"
