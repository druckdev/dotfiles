## Author:  druckdev
## Created: 2019-01-16

# Helper functions for this file. Are `unfunction`ed at the end.
	is_exec() {
		(( $# > 0 )) || return 1
		(( $+commands[$1] || $+aliases[$1] || $+functions[$1] ))
	}

	add_flags() {
		(( $# >= 2 )) || (( $+commands[$1])) || return 0

		alias "$1"="${aliases[$1]:-$1} ${*[2,-1]}"
	}

# Create aliases for coreutils versions of commands under OSX.
# NOTE: This should come before any other alias definitions of these commands as
#       otherwise this block would overwrite them.
if [[ $OSTYPE =~ darwin && -e /usr/local/Cellar/coreutils ]]; then
	for f in /usr/local/Cellar/coreutils/*/bin/g*; do
		no_gnu_file="${f/bin\/g/bin\/}"
		[[ -e $f && ! -e $no_gnu_file ]] || continue

		alias "${no_gnu_file:t}"="${f:t}"
	done
	unset f no_gnu_file
fi

# Default flags
	(( ! $+functions[ls-show-hidden] )) ||
		alias ls='ls-show-hidden --color=auto --group-directories-first -p -v'
	add_flags grep --color=auto --exclude-dir=.git --exclude=tags
	add_flags cp -i
	add_flags mv -i
	add_flags rm -I
	add_flags less -N
	add_flags lsblk -o NAME,LABEL,FSTYPE,SIZE,FSAVAIL,MOUNTPOINT
	add_flags feh -.
	# Use multiple jobs when making
	add_flags make -j
	# Bulk renaming with (almost) all files and directly modifying the
	# destination.
	add_flags qmv -Af destination-only

# XDG Base Directory Specification
	add_flags tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
	add_flags yarn --use-yarnrc "${XDG_CONFIG_HOME:-$HOME/.config}"/yarn/config
	add_flags bash --rcfile "${XDG_CONFIG_HOME:-$HOME/.config}"/bash/bashrc
	add_flags mbsync -c "$XDG_CONFIG_HOME"/isync/mbsyncrc

# Global
	alias -g G='| grep'
	alias -g no1='>/dev/null'
	alias -g no2='2>/dev/null'
	alias -g noO='&>/dev/null'

# Git
	alias g='git'
	alias gs='git status --short'
	alias ga='git add'
	alias gap='git add -p'
	alias gc='git commit'
	alias gcd='cd "$(git rev-parse --show-toplevel)"'
	alias gch='git checkout'
	alias gd='git diff'
	alias gds='git diff --staged'
	alias gf='git fetch'
	alias gp='git push'
	alias gpush='git push'
	alias gpull='git pull'
	alias gl='glog'
	alias gl{l,ogg}='glog --branches --remotes'
	alias gr='git rebase'
	alias grc='git rebase --continue'
	alias grcia='git rebase --committer-date-is-author-date'
	alias gri='git rebase -i'
	alias gss='git stash'
	# inspired by but modified:
	# https://nilansanjaya.wordpress.com/2017/06/02/git-find-base-branch/
	git_bb='git show-branch -a 2>/dev/null'
	git_bb+=' | grep "^[^[]*[*-].*\["'
	git_bb+=' | grep -v "^[^[]*\[$(git rev-parse --abbrev-ref HEAD)[]~^]"'
	git_bb+=' | head -n1'
	git_bb+=' | sed -E "s/^[^[]*\[([^]~^]*).*$/\1/"'
	alias git-base-branch="$git_bb"
	unset git_bb
	# https://stackoverflow.com/a/1549155
	alias git-ancestor='git merge-base "$(git-base-branch)" HEAD'

# Clipboard
	(( ! $+commands[perl] )) || SETCLIP_PREFIX="perl -pe 'chomp if eof' | "
	if [[ $OSTYPE =~ darwin ]]; then
		(( ! $+commands[pbpaste] )) || alias getclip="pbpaste"
		(( ! $+commands[pbcopy] ))  || alias setclip="${SETCLIP_PREFIX}pbcopy"
	elif (( $+commands[xclip] )); then
		alias getclip="xclip -selection c -o"
		alias setclip="${SETCLIP_PREFIX}xclip -selection c"
	fi
	unset SETCLIP_PREFIX

# Save keystrokes and my memory
	alias la='ls -A'
	alias l='ls -lh --time-style=long-iso'
	alias ll='l -A'
	alias cd..='cd ..'
	alias cl='() { cd "$@" && ls }'
	alias rd='rmdir'
	alias md='mkdir -p'
	alias o='xdg-open'
	alias :{q,Q}='exit'
	alias pdf2t{e,}xt='pdftotext'
	alias battery='cat /sys/class/power_supply/BAT0/capacity'
	alias loadhist='fc -RI'
	alias resetCursor='echo -ne "\e[5 q"'
	alias makeThisScratchpad='echo -ne "\033]0;scratchpad-terminal\007"'
	alias py='python3'
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
	# Disable globbing
	alias zmv='noglob zmv'
	# Automatically change into new directory (if only one was passed)
	alias mkdir='mkcd'
	# List human readable sizes in order
	alias sizes='du -sch * | sort -h'

# External command depending aliases
	(( ! $+commands[zathura] )) ||
		alias pdf='zathura --fork &>/dev/null'
	(( ! $+commands[geeqie] )) ||
		alias geeqie='launch qeeqie'
	(( ! $+commands[trash] )) ||
		alias rm='trash'
	if (( $+commands[xxd] )); then
		alias hex='xxd'
		alias bin='xxd -b -c4 | cut -d" " -f2-5'
	fi
	if (( $+commands[nvim] )); then
		alias vim='jobs | grep -q nvim && {fg;:;} || nvim'
		alias vimdiff='nvim --cmd "set list" -c "set listchars=tab:>·,space:·" -d'
	fi
	! is_exec vim ||
		alias vi='vim'
	! is_exec vi ||
		alias v='vi'
	(( ! $+commands[man] )) ||
		alias man='nvim-man'

unfunction add_flags is_exec
