## Author:  druckdev
## Created: 2019-01-16

# Default flags
	alias ls='ls --color=auto --group-directories-first -p -v'
	alias grep='grep --color'
	alias cp='cp -i'
	alias mv='mv -i'
	alias rm='rm -I'
	alias less='less -N'
	alias lsblk='lsblk -f'
	alias feh='feh -.'

# XDG Base Directory Specification
	alias wget='
		wget --config="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc" \
		     --hsts-file="${XDG_DATA_HOME:-$HOME/.local/share}/wget/wget-hsts"
	'
	alias tmux='tmux -f "$HOME/.config/tmux/tmux.conf"'
	alias tmsu='tmsu -D "${XDG_DATA_HOME:-$HOME/.local/share}/tmsu/db"'

# Global
	alias -g G='| grep'
	alias -g no2='2>/dev/null'

# Git
	alias gs='git status --short'
	alias ga='git add'
	alias gc="git commit"
	alias gpush='git push'
	alias gpull='git pull'
	alias gd='git diff'
	# Commit, but put the last written commit message into the editor buffer.
	# Useful for example when the commit-msg hook fails but only slight
	# modifications are needed.
	alias git-commit-last-msg='() {
		local gitdir="$(git rev-parse --git-dir)" || return
		git commit -eF <(grep -v "^#" "$gitdir/COMMIT_EDITMSG")
	}'

# Save keystrokes and my memory
	alias la='${aliases[ls]:-ls} -A'
	alias l='${aliases[ls]:-ls} -lh --time-style=long-iso'
	alias ll='${aliases[l]} -A'
	alias cd..='cd ..'
	alias cl='() { cd "$@" && ${aliases[ls]:-[ls]}'
	alias getclip="xclip -selection c -o"
	alias setclip="perl -pe 'chomp if eof' | xclip -selection c"
	alias pdf='launch evince'
	alias darkpdf='launch zathura'
	alias geeqie='launch qeeqie'
	alias trash-restore='restore-trash'
	alias rd='rmdir'
	alias md='mkdir -p'
	alias o='xdg-open'
	alias :{q,Q}='exit'
	alias update='
		sudo apt update \
		&& sudo apt upgrade -y \
		&& sudo apt autoremove -y

		[[ ! -e /var/run/reboot-required ]] \
		|| printf "\n\nSystem restart required.\n"
	'
	alias pdf2t{e,}xt='pdftotext'
	alias rm='printf "\033[1;031mUse trash!\n\033[0m"; false'
	alias battery='
		upower -i /org/freedesktop/UPower/devices/battery_BAT0
		| grep -E "to full|percentage"
		| tr -d " "
		| sed "s/:/: /"
	'
	alias qrdecode='zbarimg'
	alias loadhist='fc -RI'
	alias hex=xxd
	alias bin='xxd -b -c4 | cut -d" " -f2-5'
	! command -v nvim &>/dev/null || alias vim=nvim
	alias vi='${aliases[vim]:-vim}'
	alias resetCursor='echo -ne "\e[5 q"'
	alias makeThisScratchpad='echo -ne "\033]0;scratchpad-terminal\007"'
	# grep filenames and date entries in exiftool
	alias grepdate='grep -E "(={8})|([:0-9]{10} [:0-9]{8})"'
	# 'Temporary' shell in alternate mode for hiding commands in scrollback.
	alias tmpshell='tput smcup && zsh && tput rmcup'
	# List options and their value (on|off) line by line. This makes it a lot
	# easier to grep for activated options than using `setopt` and `unsetopt`.
	alias listopts='printf "%s %s\n" "${(kv)options[@]}"'
	# Launch program independent and detached from shell.
	alias launch='() { ${aliases[$1]:-$1} "${@[2,-1]}" &>/dev/null &| }'
	# Create copy with .bkp extension
	alias bkp='() { for f; do command cp -i "$f"{,.bkp}; done }'
	# Reverse bkp()
	alias unbkp='() { for f; do command cp -i "$f" "${f%.bkp}; done }'
	# Grep in history file
	alias histgrep='() { grep "$@" "${HISTFILE:-$HOME/.zsh_history}" }'
	# URL-encode
	alias urlenc='() {
		python3 -c "from urllib import parse; print(parse.quote('$@'), end='')
	}'
	# URL-decode
	alias urldec='() {
		python3 -c "from urllib import parse; print(parse.unquote('$@'), end='')
	}'

# Named directories
	hash -d docs="$HOME"/Documents/
	hash -d cheat="${nameddirs[docs]}"/cheat_sheets
	hash -d proj="$HOME"/Projects/
	hash -d dot{,s}="${nameddirs[proj]}"/github/dotfiles-github/
	hash -d pics="$HOME"/Pictures/
	hash -d down="$HOME"/Downloads/

	hash -d uni="${nameddirs[docs]}"/uni
	local UNI="${nameddirs[uni]}"
	hash -d wise="$(printf "%s\n" "$UNI"/[0-9][0-9]-WiSe | tail -1)"
	hash -d sose="$(printf "%s\n" "$UNI"/[0-9][0-9]-SoSe | tail -1)"
