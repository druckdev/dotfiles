#!/bin/sh

if [ "$(rfkill -o SOFT --noheadings list wlan)" = "blocked" ]; then
    notify-send "Airplane mode toggled" "On"
else
    notify-send "Airplane mode toggled" "Off"
fi

