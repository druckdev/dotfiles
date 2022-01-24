#!/bin/sh

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
xset r rate 400 35

touchpad="DLL082A:01 06CB:76AF Touchpad"
xinput set-prop "$touchpad" "libinput Tapping Enabled" 1
xinput set-prop "$touchpad" "libinput Natural Scrolling Enabled" 1
xinput set-prop "$touchpad" "libinput Accel Speed" 0.45
unset touchpad

# Muted at startup
amixer -q -D pulse sset Master mute

# Compositor
compositor="${XDG_CONFIG_HOME:-$HOME/.config}"/compositor/launch.sh
[ ! -x "$compositor" ] || "$compositor"
unset compositor

# Wallpaper
wallpaper="$HOME"/pics/wallpapers/wallpaper
feh --bg-scale --no-fehbg "$wallpaper"
unset wallpaper

# Locker
locker="${XDG_CONFIG_HOME:-$HOME/.config}"/locker/launch.sh
[ ! -x "$locker" ] || "$locker"
unset locker

exec i3
