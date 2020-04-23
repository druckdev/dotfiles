#!/bin/sh

## config

full=80
low=20

############################

red='%{F#f00}'
green='%{F#0f0}'
end='%{F-}'
# hack to put a little space between the lightning and the percentage
smallspace='%{T4} %{T-}'

bat="$(cat /sys/class/power_supply/BAT0/capacity)"
ac="$(cat /sys/class/power_supply/AC/online)"

# display in red when under $low and no charger is connected
[ "$bat" -gt "$low" ] || [ "$ac" -eq 1 ] || color="$red"
# display in green when over $full and a charger is connected
[ "$bat" -lt "$full" ] || [ "$ac" -eq 0 ] || color="$green"

prefix=" "
[ "$ac" -eq 0 ] || prefix="⚡"

echo "${color}${prefix}${smallspace}${bat}%"
