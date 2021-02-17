# vim: ft=zsh

# Less clutter in $HOME by enforcing the XDG Base Directory specification.
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_DATA_HOME:=$HOME/.local/share}
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME

export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority

export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export MPLAYER_HOME="$XDG_CONFIG_HOME"/mplayer
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrcü

export HISTFILE="$XDG_DATA_HOME"/bash/history
export LESSHISTFILE=/dev/null
export SQLITE_HISTORY="$XDG_DATA_HOME"/sqlite3/sqlite_history
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

VIMINIT="let \$MYVIMRC=\"$XDG_CONFIG_HOME/vim/xdg.vim\" | source \$MYVIMRC"
export VIMINIT

export ANDROID_AVD_HOME="$XDG_DATA_HOME"/android/
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME"/android/
export ADB_VENDOR_KEY="$XDG_CONFIG_HOME"/android
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android

export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export VSCODE_EXTENSIONS="$XDG_DATA_HOME"/vscode/extensions

# Other environment variables
if [[ ! "$PATH" =~ "$HOME/\.local/bin" ]]; then
	export PATH="$HOME/.local/bin${PATH:+:$PATH}"
fi

# Locale settings as $LANG
[[ ! -e "$XDG_CONFIG_HOME/locale.conf" ]] || . "$XDG_CONFIG_HOME/locale.conf"

if (( $+commands[nvim] )); then
	export EDITOR=nvim
elif (( $+commands[vim] )); then
	export EDITOR=vim
elif (( $+commands[vi] )); then
	export EDITOR=vi
elif (( $+commands[nano] )); then
	export EDITOR=nano
fi

if (( $+commands[nvim] )); then
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

# Show also hidden files per default but ignore files in '.git' directories.
if (( $+commands[rg] )); then
	# Also respect gitignores
	FZF_DEFAULT_COMMAND="rg --hidden --files -g '!.git'"
else
	FZF_DEFAULT_COMMAND="find . -name '.git' -prune -o \( -type f -a -print \)"
fi
export FZF_DEFAULT_COMMAND

# Setup LS_COLORS
if (( $+commands[dircolors] )); then
	if [[ -e "$XDG_CONFIG_HOME"/dircolors/dircolors ]]; then
		eval "$(dircolors -b "$XDG_CONFIG_HOME"/dircolors/dircolors)"
	else
		eval "$(dircolors -b)"
	fi
fi

# Automatically start X on login after boot.
[[ -n $DISPLAY || $XDG_VTNR -ne 1 ]] || exec startx
