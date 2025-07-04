## Author:  druckdev
## Created: 2019-01-16

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

# Global
	alias -g G='| grep'
	alias -g no1='>/dev/null'
	alias -g no2='2>/dev/null'
	alias -g noO='&>/dev/null'
	# Manually trigger alias expansion for the next word
	# Taken from https://unix.stackexchange.com/a/433849
	alias -g '$= '
	# Don't clutter scrollback with help pages
	alias -g -- '--help'='--help | less'

# Git
	alias g='git'
	alias ga='git add'
	alias gap='git add -p'
	alias gc='git commit'
	alias gca='git commit --amend'
	alias gcd='cd "$(git rev-parse --show-toplevel)"'
	alias gch='git checkout'
	alias gcl='git commit-last-msg'
	alias gclm='git commit-last-msg'
	alias gco='git checkout'
	alias gcow='git checkout-worktree'
	alias gd='git diff'
	alias gds='git diff --staged'
	alias gf='git fetch'
	alias gha='git add -p'
	alias gl='glog --no-merges'
	alias gla='glog --branches --remotes --tags HEAD'
	alias {gll,glg}='glog --graph'
	alias {glll,glla,glga,glag,glogg}='gla --graph'
	alias gp='git push'
	alias gpf='git push --force-with-lease --force-if-includes'
	alias gpull='git pull'
	alias gpush='git push'
	alias gr='git reset'
	alias grc='git rebase --continue'
	alias grcia='git rebase --committer-date-is-author-date'
	alias gri='git rebase -i'
	alias gs='git status --short'
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
	(( ! $+functions[ls-show-hidden] )) || alias ls='ls-show-hidden'
	alias la='ls -A'
	alias l='ls -lh --time-style=long-iso'
	alias ll='l -A'
	alias lsd='ls -d *(/)'
	alias cd..='cd ..'
	alias cl='() { cd "$@" && ls }'
	alias rd='rmdir'
	alias md='mkdir'
	alias o='xdg-open'
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
	# List human readable sizes in order
	alias sizes='du -sch * | sort -h'
	# Count number of occurrences for every line in stdin
	alias count='sort | uniq -c | sort -n'
	# Inspired by https://stackoverflow.com/a/54541337
	#     > echo 1747502 | duration
	#     20d 5h 25m 2s
	#
	# TODO: do not print values if they are zero
	alias duration="dc -e '?60~r60~r24~rn[d ]nn[h ]nn[m ]nn[s]p'"
	alias udsk='udisksctl'
	# calculator with output in hex (goes well together with option C_BASES)
	alias hex='() { printf "%s\n" "$(([#16] $*))" }'
	# https://unix.stackexchange.com/a/309781
	alias bytestr='hexdump -v -e '\''"\\" "x" 1/1 "%02X"'\'

# Precommand modifiers
	alias mkdir='nocorrect mkdir'
	alias zmv='noglob zmv'

# Helper functions for this file. Are `unfunction`ed at the end.
	is_exec() {
		(( $# > 0 )) || return 1
		(( $+commands[$1] || $+aliases[$1] || $+functions[$1] ))
	}

	add_flags() {
		(( $# >= 2 )) || (( $+commands[$1])) || return 0

		alias "$1"="${aliases[$1]:-$1} ${*[2,-1]}"
	}

# External command depending aliases
	(( ! $+commands[zathura] )) ||
		alias pdf='zathura --fork &>/dev/null'
	(( ! $+commands[geeqie] )) ||
		alias geeqie='launch qeeqie'
	(( ! $+commands[trash] )) ||
		alias rm='trash'
	if (( $+commands[xxd] )); then
		alias bin='xxd -b -c4 | cut -d" " -f2-5'
	fi
	if (( $+commands[nvim] )); then
		# TODO: keep exit code of fg, Add files (if args exist) to running vim
		#       session in a new tab or split
		alias vim='jobs | grep -q nvim && {fg;:;} || nvim'
		alias vimdiff='nvim -d'
	fi
	! is_exec vim ||
		alias vi='vim'
	! is_exec vi ||
		alias v='vi'

# Default flags
	add_flags ls --color=auto --group-directories-first -p -v
	add_flags grep --color=auto --exclude-dir=.git --exclude=tags
	add_flags cp -i
	add_flags mv -i
	# Only add flags if rm is not aliased to a different command (e.g. trash).
	# NOTE: This also works if rm is not yet aliased.
	# TODO: This breaks for a single word alias containing the substring `rm`,
	#       as then there is no word splitting anymore.
	(( ${${aliases[rm]}[(ei)rm]} > ${#${aliases[rm]}} )) ||
		add_flags rm -I
	add_flags mkdir -p
	add_flags lsblk -o NAME,LABEL,TYPE,FSTYPE,SIZE,FSAVAIL,MOUNTPOINT
	add_flags feh --start-at
	# Use multiple jobs when making
	add_flags make -j
	# Bulk renaming with (almost) all files and directly modifying the
	# destination.
	add_flags qmv -Af destination-only
	# Match against and list full command line
	add_flags pgrep --full --list-full

# XDG Base Directory Specification
	add_flags tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
	add_flags yarn --use-yarnrc "${XDG_CONFIG_HOME:-$HOME/.config}"/yarn/config
	add_flags bash --rcfile "${XDG_CONFIG_HOME:-$HOME/.config}"/bash/bashrc

unfunction add_flags is_exec
