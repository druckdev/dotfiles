## Author:  druckdev
## Created: 2019-10-21

setopt NO_GLOBAL_RCS

if [ -n "$DESKTOP_SESSION" ]; then
    eval $(/usr/bin/gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

[ ! -r "$ZDOTDIR/.zshenv" ] || . "$ZDOTDIR/.zshenv"
