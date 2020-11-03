# vim: ft=zsh

# Less clutter in $HOME by enforcing the XDG Base Directory specification.
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_DATA_HOME:=$HOME/.local/share}
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME

export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority

export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go

export HISTFILE="$XDG_DATA_HOME"/bash/history
export LESSHISTFILE=/dev/null
export SQLITE_HISTORY="$XDG_DATA_HOME"/sqlite3/sqlite_history

VIMINIT="let \$MYVIMRC=\"$XDG_CONFIG_HOME/vim/xdg.vim\" | source \$MYVIMRC"
export VIMINIT

export ANDROID_AVD_HOME="$XDG_DATA_HOME"/android/
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME"/android/
export ADB_VENDOR_KEY="$XDG_CONFIG_HOME"/android
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android

# Other environment variables
if [[ ! "$PATH" =~ "$HOME/\.local/bin" ]]; then
	export PATH="$HOME/.local/bin${PATH:+:$PATH}"
fi

if command -v nvim &>/dev/null; then
	export EDITOR=nvim
elif command -v vim &>/dev/null; then
	export EDITOR=vim
elif command -v vi &>/dev/null; then
	export EDITOR=vi
elif command -v nano &>/dev/null; then
	export EDITOR=nano
fi

if command -v nvim &>/dev/null; then
	export MANPAGER="nvim -c 'set ft=man' -"
else
	# https://www.tecmint.com/view-colored-man-pages-in-linux/
	export LESS_TERMCAP_mb=$'\e[1;32m'
	export LESS_TERMCAP_md=$'\e[1;32m'
	export LESS_TERMCAP_me=$'\e[0m'
	export LESS_TERMCAP_se=$'\e[0m'
	export LESS_TERMCAP_so=$'\E[01;44;33m'
	export LESS_TERMCAP_ue=$'\e[0m'
	export LESS_TERMCAP_us=$'\e[1;4;31m'
fi

# Automatically start X on login after boot.
[[ -n $DISPLAY || $XDG_VTNR -ne 1 ]] || exec startx
