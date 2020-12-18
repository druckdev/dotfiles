## Author:  druckdev
## Created: 2019-01-16

# Default flags
	alias ls='ls-show-hidden --color=auto --group-directories-first -p -v'
	alias grep='grep --color'
	alias cp='cp -i'
	alias mv='mv -i'
	alias rm='rm -I'
	alias less='less -N'
	alias lsblk='lsblk -o NAME,LABEL,FSTYPE,SIZE,FSAVAIL,MOUNTPOINT'
	alias feh='feh -.'

# XDG Base Directory Specification
	alias tmux='tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"'
	alias tmsu='tmsu -D "${XDG_DATA_HOME:-$HOME/.local/share}/tmsu/db"'
	alias yarn='yarn --use-yarnrc "${XDG_CONFIG_HOME:-$HOME/.config}"/yarn/config'
	alias bash='bash --rcfile "${XDG_CONFIG_HOME:-$HOME/.config}"/bash/bashrc'

# Global
	alias -g G='| grep'
	alias -g no2='2>/dev/null'

# Git
	alias g='git'
	alias gs='git status --short'
	alias ga='git add'
	alias gc="git commit"
	alias gpush='git push'
	alias gpull='git pull'
	alias gd='git diff'
	alias gl='git log'
	alias gss='git stash'

# Save keystrokes and my memory
	alias la='ls -A'
	alias l='ls -lh --time-style=long-iso'
	alias ll='l -A'
	alias cd..='cd ..'
	alias cl='() { cd "$@" && ls }'
	alias getclip="xclip -selection c -o"
	alias setclip="perl -pe 'chomp if eof' | xclip -selection c"
	alias pdf='zathura --fork &>/dev/null'
	alias geeqie='launch qeeqie'
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
	alias battery='cat /sys/class/power_supply/BAT0/capacity'
	alias qrdecode='zbarimg'
	alias loadhist='fc -RI'
	alias hex='xxd'
	alias bin='xxd -b -c4 | cut -d" " -f2-5'
	! command -v nvim &>/dev/null || alias vim=nvim
	alias vi='vim'
	alias vimdiff='vim --cmd "set list" -c "set listchars=tab:>·,space:·" -d'
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
	# Launch program after reducing the screen resolution.
	alias lowres='() {
		xrandr -s 1920x1080; $1 "${@[2,-1]}"; xrandr -s 3200x1800
	}'
	# Create copy with .bkp extension
	alias bkp='() { for f; do command cp -i "$f"{,.bkp}; done }'
	# Reverse bkp()
	alias unbkp='() { for f; do command cp -i "$f" "${f%.bkp}; done }'
	# Grep in history file
	alias histgrep='() { grep "$@" "${HISTFILE:-$HOME/.zsh_history}" }'
	# URL-encode
	alias urlenc='() {
		python3 -c \
			"from urllib import parse; print(parse.quote(\"$*\"), end=\"\")"
	}'
	# URL-decode
	alias urldec='() {
		python3 -c \
			"from urllib import parse; print(parse.unquote(\"$*\"), end=\"\")"
	}'
	# Workaround for stack smash when using stderred
	alias gpg='\
		env LD_PRELOAD="$(
			sed "s/[^:]*libstderred.so:\?//;s/:$//" <<<"$LD_PRELOAD"
		)" gpg'
	# Use a reasonable time format
	alias date='env LC_TIME=tk_TM date'

# Named directories
	for dir in "$HOME"/[^.]*(/); do
		[[ ! ${dir:t} =~ " " ]] || continue
		hash -d ${dir:t}="$dir"
	done

	hash="$(xdg-user-dir DOCUMENTS 2>/dev/null || echo docs)"
	hash="$(basename "$hash")"
	if (( $+nameddirs[$hash] )); then
		hash -d cheat=~$hash/cheat_sheets
		hash -d uni=~$hash/uni
		hash -d work=~$hash/work
	fi
	unset hash
	if (( $+nameddirs[projs] )); then
		hash -d dot{,s}=~projs/dotfiles
	fi
	if (( $+nameddirs[uni] )); then
		# Use the first match in ~uni/[0-9][0-9]-{So,Wi}Se sorted in descending
		# numeric order (most recent semester). The echo is necessary as else
		# filename generation will include the wise= and nothing is matched.
		# TODO!
		hash -d sose="$(echo ~uni/[0-9][0-9]-SoSe(NnOn[1]))"
		hash -d wise="$(echo ~uni/[0-9][0-9]-WiSe(NnOn[1]))"
	fi
