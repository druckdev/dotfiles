#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2020 - 2024 Julian Prein

sysresources=/etc/X11/xinit/.Xresources
userresources="${XDG_CONFIG_HOME:-$HOME/.config}"/X11/xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
usermodmap="${XDG_CONFIG_HOME:-$HOME/.config}"/X11/xmodmap
sysxinitrcd=/etc/X11/xinit/xinitrc.d
userxinitrcd="${XDG_CONFIG_HOME:-$HOME/.config}"/X11/xinitrc.d

[ ! -f "$sysresources" ] || xrdb -merge "$sysresources"
[ ! -f "$userresources" ] || xrdb -merge "$userresources"

[ ! -f "$sysmodmap" ] || xmodmap "$sysmodmap"
[ ! -f "$usermodmap" ] || xmodmap "$usermodmap"

if [ -d "$sysxinitrcd" ] ; then
	for f in "$sysxinitrcd"/?*.sh ; do
		[ ! -x "$f" ] || . "$f"
	done
	unset f
fi

if [ -d "$userxinitrcd" ] ; then
	for f in "$userxinitrcd"/?*.sh ; do
		[ ! -x "$f" ] || . "$f"
	done
	unset f
fi

unset {sys,user}{resources,modmap,xinitrcd}

# <right-CTRL> acts as <ESC> when pressed alone and shortly.
# ! command -v xcape || xcape -t 250 -e 'Control_R=Escape'
# Key repeat rate
xset r rate 300 50

if command -v xinput >/dev/null 2>&1; then
	touchpad="DLL082A:01 06CB:76AF Touchpad"
	xinput set-prop "$touchpad" "libinput Tapping Enabled" 1
	xinput set-prop "$touchpad" "libinput Natural Scrolling Enabled" 1
	xinput set-prop "$touchpad" "libinput Accel Speed" 0.45
	unset touchpad
fi

# Muted at startup
! command -v amixer >/dev/null 2>&1 || amixer -q -D pulse sset Master mute

# Compositor
compositor="${XDG_CONFIG_HOME:-$HOME/.config}"/compositor/launch.sh
[ ! -x "$compositor" ] || "$compositor"
unset compositor

# Wallpaper
wallpaper="$HOME"/media/pics/wallpapers/wallpaper
! command -v feh >/dev/null 2>&1 || feh --bg-scale --no-fehbg "$wallpaper"
unset wallpaper

# Locker
locker="${XDG_CONFIG_HOME:-$HOME/.config}"/locker/launch.sh
[ ! -x "$locker" ] || "$locker"
unset locker

! command -v i3 >/dev/null 2>&1 || exec i3
