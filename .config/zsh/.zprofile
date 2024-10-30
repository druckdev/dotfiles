# vim: ft=zsh

# Less clutter in $HOME by enforcing the XDG Base Directory specification.
: ${XDG_STATE_HOME:=$HOME/.local/state}
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_DATA_HOME:=$HOME/.local/share}
export XDG_{CONFIG,CACHE,DATA}_HOME

export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority

export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export MPLAYER_HOME="$XDG_CONFIG_HOME"/mplayer
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NVM_DIR="$XDG_DATA_HOME"/nvm
export KODI_DATA=$XDG_DATA_HOME/kodi
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export PYLINTHOME="${XDG_CACHE_HOME}"/pylint
export PYTHONSTARTUP="${XDG_CONFIG_HOME}"/python/pythonrc
export MBSYNCRC="$XDG_CONFIG_HOME"/isync/mbsyncrc
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME"/ripgrep/config

export HISTFILE="$XDG_DATA_HOME"/bash/history
export LESSHISTFILE=/dev/null
export SQLITE_HISTORY="$XDG_DATA_HOME"/sqlite3/sqlite_history
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

VIMINIT="let \$MYVIMRC=\"$XDG_CONFIG_HOME/vim/xdg.vim\" | source \$MYVIMRC"
export VIMINIT

export ANDROID{,_AVD,_EMULATOR}_HOME="$XDG_DATA_HOME"/android
export ADB_VENDOR_KEYS="$XDG_CONFIG_HOME"/android
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android

export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export VSCODE_EXTENSIONS="$XDG_DATA_HOME"/vscode/extensions

# Other environment variables
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
	export PATH="/usr/local/bin${PATH:+:$PATH}"
fi
if [[ ! "$PATH" =~ "$HOME/\.local/bin" ]]; then
	export PATH="$HOME/.local/bin${PATH:+:$PATH}"
fi
if [[ ! $PATH =~ "$HOME/\.local/share/npm/bin" ]]; then
	export PATH="${PATH:+$PATH:}$HOME/.local/share/npm/bin"
fi
if [[ $OSTYPE =~ darwin && ! $PATH =~ "/Library/Apple/usr/bin" ]]; then
	export PATH="${PATH:+$PATH:}/Library/Apple/usr/bin"
fi
if [[ $GOPATH && -e $GOPATH && ! $PATH =~ $GOPATH/bin ]]; then
	export PATH="${PATH:+$PATH:}$GOPATH/bin"
fi
if [[ -d /usr/bin/vendor_perl/ && ! $PATH =~ /usr/bin/vendor_perl/ ]]; then
	export PATH="${PATH:+$PATH:}/usr/bin/vendor_perl"
fi

export ZETTELKASTEN_NOTES="$HOME/docs/notes"

# Locale settings as $LANG
[[ ! -e "$XDG_CONFIG_HOME/locale.conf" ]] || . "$XDG_CONFIG_HOME/locale.conf"

# SSH
if (( $+commands[ssh-agent] )) && [[ ! $SSH_AGENT_PID ]]; then
	eval "$(ssh-agent)" >/dev/null
	# See .zlogout
	LAUNCHED_SSH_AGENT=1
fi

# Terminal
if (( $+commands[st] )); then
	export TERMINAL=st
fi

# Editor
if (( $+commands[nvim] )); then
	export EDITOR=nvim
elif (( $+commands[vim] )); then
	export EDITOR=vim
elif (( $+commands[vi] )); then
	export EDITOR=vi
elif (( $+commands[nano] )); then
	export EDITOR=nano
fi

# Less
# https://www.tecmint.com/view-colored-man-pages-in-linux/
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

unset LESS
# Enable mouse wheel support
LESS+="${LESS:+ }--mouse --wheel-lines=3"
# Display ANSI color escape sequences
LESS+="${LESS:+ }--RAW-CONTROL-CHARS"
# Exit if entire file fits on screen
# NOTE: Before v530 `less` would need the -X flag as well for -F to be useful.
#       With v530 it does not enter alternate mode if the content fits in one
#       screen.
LESS+="${LESS:+ }--quit-if-one-screen"
export LESS

# Use neovim's man plugin as manpager
(( ! $+commands[nvim] )) || \
	export MANPAGER='nvim +"Man! | set scrolloff=999 | normal M"'

# NOTE: This is used in keys.zsh for the ALT_C widget
FZF_DEFAULT_COMMAND_FALLBACK="find -L . -mindepth 1 \("
	FZF_DEFAULT_COMMAND_FALLBACK+=" -name '.git' -o"
	FZF_DEFAULT_COMMAND_FALLBACK+=" -name '__pycache__' -o"
	FZF_DEFAULT_COMMAND_FALLBACK+=" -name 'venv' -o"
	FZF_DEFAULT_COMMAND_FALLBACK+=" -name 'build' -o"
	FZF_DEFAULT_COMMAND_FALLBACK+=" -name 'tex_build' -o"
	FZF_DEFAULT_COMMAND_FALLBACK+=" -name 'node_modules'"
FZF_DEFAULT_COMMAND_FALLBACK+=" \) -prune -o -type f -print"
FZF_DEFAULT_COMMAND_FALLBACK+=" 2>/dev/null"
FZF_DEFAULT_COMMAND_FALLBACK+=" | cut -c3-"
export FZF_DEFAULT_COMMAND_FALLBACK

# Ignore gitignore(5)d files, see also $XDG_CONFIG_HOME/git/ignore
if (( $+commands[fd] )); then
	FZF_DEFAULT_COMMAND="fd -L --hidden --type f --no-require-git"
	FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND/-type f/-type d}"
elif (( $+commands[rg] )); then
	FZF_DEFAULT_COMMAND="rg -L --hidden --files --no-require-git"
	FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND_FALLBACK/-type f/-type d}"
else
	# Fallback to hardcoding the most important paths to prune
	FZF_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND_FALLBACK"
	FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND_FALLBACK/-type f/-type d}"
fi
export FZF_DEFAULT_COMMAND

if (( $+commands[bfs] )); then
	FZF_ALT_C_COMMAND="${${FZF_DEFAULT_COMMAND_FALLBACK/-type f/-type d}/#find/bfs}"
fi

typeset -A fzf_keys=(
	# Clear query if not empty, abort otherwise
	esc    cancel
	# Better navigation
	home   first
	end    last
	ctrl-d half-page-down
	ctrl-u half-page-up
	ctrl-t toggle-track
	# Keep the current line selected while deleting the query
	bspace       track-current+backward-delete-char
	backward-eof untrack-current
)
# NOTE: Use a subshell to temporarily enable EXTENDED_GLOB needed by the (#m)
# globbing flag, since the (*) parameter expansion flag was "only" introduced in
# zsh-5.8.1.2-test
FZF_DEFAULT_OPTS="$(
	emulate -L zsh -o extendedglob
	printf " --bind %s" "${(@kj:,:)fzf_keys/(#m)*/$MATCH:$fzf_keys[$MATCH]}"
)"
unset fzf_keys

FZF_DEFAULT_OPTS+=" --highlight-line"
export FZF_DEFAULT_OPTS

# Setup LS_COLORS
if (( $+commands[dircolors] )); then
	if [[ -e "$XDG_CONFIG_HOME"/dircolors/dircolors ]]; then
		eval "$(dircolors -b "$XDG_CONFIG_HOME"/dircolors/dircolors)"
	else
		eval "$(dircolors -b)"
	fi
fi

# Source private zprofile
[[ ! -e "${(%):-%x}.priv" ]] || . "${(%):-%x}.priv"

# Automatically start X on login after boot.
# Do not use exec so that the zlogout is still read.
if (( $+commands[startx] )) && [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	startx
	exit $?
fi

# Attach to tmux session if connected over ssh and not already attached
if (( $+commands[tmux] )) &&
	[[ (-n $SSH_CLIENT || -n $SSH_TTY || -n $SSH_CONNECTION) && -z $TMUX ]]
then
	TMUX_CMD=(tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf")
	num_sessions="$("${TMUX_CMD[@]}" list-sessions 2>/dev/null | wc -l)"

	if (( ! num_sessions )); then
		"${TMUX_CMD[@]}"
	elif (( num_sessions == 1 )); then
		"${TMUX_CMD[@]}" attach
	else
		"${TMUX_CMD[@]}" attach\; choose-tree -Zs
	fi

	# NOTE: Do not use exec so that the zlogout is still read.
	exit $?
fi
# NOTE: nothing should be placed behind this except for stuff that is sure that
#       `tmux` was not called
