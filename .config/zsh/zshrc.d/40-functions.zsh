## Author:  druckdev
## Created: 2019-08-28

## Compares two pdfs based on the result of pdftotext
pdfdiff() {
	if [[ $# -eq 2 && -r "$1" && -r "$2" ]]; then
		diff <(pdftotext "$1" -) <(pdftotext "$2" -)
	else
		echo "something went wrong" 2>&1
		return 1
	fi
}

## Gets Passwd from bitwarden and copies it into the clipboard
bwpwd() {
	if bw "get" "password" "$@" >/dev/null; then
		bw "get" "password" "$@" | tr -d '\n' | setclip
	else
		bw "get" "password" "$@"
	fi
}

## creates directory and changes into it
mkcd () {
	# Create directory
	mkdir "$@"
	# shift arguments if mkdir options were used
	while [[ $# -gt 1 ]]; do
		shift
	done
	if [[ -d "$1" ]]; then
		cd "$1"
		pwd
	fi
}

## Encode and decode qr-codes
qr() {
	if [[ $# -eq 1 && -r "$1" ]]; then
		zbarimg "$1"
	else
		qrencode "$@"
	fi
}

## Edit config file
conf() {
	local CONF_EDITOR
	if [[ -n "$EDITOR" ]]; then
		CONF_EDITOR="$EDITOR"
	elif (( $+commands[vim] )); then
		CONF_EDITOR=vim
	elif (( $+commands[nano] )); then
		CONF_EDITOR=nano
	else
		CONF_EDITOR=cat
	fi

	# Parse otions
	while getopts "e:" opt 2>/dev/null; do
		case $opt in
			e) CONF_EDITOR="$OPTARG";;
			*) printf "\033[1;31mUsage: $0 [-e <editor>] <program>[/subdirs] [<config_file>]\n\033[0m" >&2
			   return 1 ;;
		esac
	done
	shift $(( $OPTIND - 1 ))

	# conf needs an argument
	if [[ $# -eq 0 ]]; then
		printf "\033[1;31mPlease specify a config.\n\033[0m" >&2
		return 1
	fi
	# search for program name in XDG_CONFIG_HOME and $HOME
	local CONF_DIR="$(_get_config_dir "$1")"
	if (( $? )); then
		printf "\033[1;31mFalling back to $HOME.\n\033[0m" >&2
		CONF_DIR="$HOME"
	fi

	# If specific name is given, open file.
	if [[ $# -gt 1 ]]; then
		"$CONF_EDITOR" "$CONF_DIR/$2"
		return
	fi

	# possible config-file names + same but hidden
	local -a CONF_PATTERNS
	CONF_PATTERNS=(
		"$1.conf"
		"$1.config"
		"${1}rc"
		"config"
		"conf"
		"$1.yml"
		"$1.yaml"
		"config.ini"
		"$1"
	)

	# check if config file exists
	for config in $CONF_PATTERNS; do
		if [[ -e "$CONF_DIR/$config" ]]; then
			$CONF_EDITOR "$CONF_DIR/$config"
			return 0
		elif [[ -e "$CONF_DIR/.$config" ]]; then
			$CONF_EDITOR "$CONF_DIR/.$config"
			return 0
		fi
	done

	# if no config was found in a location other than HOME, look again in HOME.
	# (For cases like default vim with ~/.vim/ and ~/.vimrc)
	if [[ "$CONF_DIR" != "$HOME" ]];then
		for config in $CONF_PATTERNS; do
			# Only look for hidden files
			if [[ -e "$HOME/.$config" ]]; then
				$CONF_EDITOR "$HOME/.$config"
				return 0
			fi
		done
	fi

	printf "\033[1;31mCould not find config file.\n\033[0m" >&2
	return 1
}

## Change into config dir
c() {
	CONF_DIR="$(_get_config_dir $*)"
	if [[ $? -eq 0 ]]; then
		cd "$CONF_DIR"
	else
		printf "$CONF_DIR" >&2
		return 1
	fi
}
## Get config directory
_get_config_dir() {
	if [[ $# -gt 1 ]]; then
		printf "\033[1;31mPlease specify one config.\n\033[0m" >&2
		return 1
	elif [[ $# -eq 0 ]]; then
		echo "${XDG_CONFIG_HOME:-$HOME/.config}"
	elif [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/$1" ]]; then
		echo "${XDG_CONFIG_HOME:-$HOME/.config}/$1"
	elif [[ -d "$HOME/.$1" ]]; then
		echo "$HOME/.$1"
	else
		printf "\033[1;31mCould not find config home.\n\033[0m" >&2
		return 1
	fi
}

## Function that resolves a command to the end
resolve() {
	local verbose cmd old_cmd args last_line
	local -a full_cmd

	# Since there are multiple occasions were the same line would be printed
	# multiple times, this function makes the output in combination with the
	# verbose flag cleaner.
	local uniq_print() {
		if [[ "$*" != "$last_line" ]]; then
			printf "%s\n" "$*"
			last_line="$*"
		fi
	}

	while getopts v flag 2>/dev/null; do
		[[ "$flag" != "v" ]] || verbose=1
	done
	shift $((OPTIND - 1))

	full_cmd=("$@")
	cmd="${full_cmd[1]}"

	(( ! verbose )) || uniq_print "${full_cmd[@]}"

	# Resolve aliases
	while [[ "$cmd" != "$old_cmd" ]]; do
		out="$(command -v "$cmd")"
		# NOTE: cannot be combined for the case that $cmd is not an alias
		out="${out#alias $cmd=}" # Extract the alias or command
		out="${${out#\'}%\'}"
		# Beware of potential empty element leading to print trailing whitespace
		if (( $#full_cmd > 1)); then
			full_cmd=($out "${full_cmd[2,-1]}")
		else
			full_cmd=($out)
		fi
		(( ! verbose )) || uniq_print "${full_cmd[@]}"
		old_cmd="$cmd"
		cmd="${full_cmd[1]}"
	done

	# Resolve symlinks
	if [[ -e "$cmd" ]]; then
		# When we are not verbose a call to realpath is sufficient and way
		# faster.
		if (( ! verbose )); then
			cmd="$(realpath "$cmd")"
			full_cmd=("$cmd" "${full_cmd[2,-1]}")
		else
			old_cmd=
			while [[ "$cmd" != "$old_cmd" ]]; do
				# Get filename with potential symlink target
				out="$(stat -c "%N" "$cmd")"
				# NOTE: cannot be combined for the case that $cmd is not symlink
				out="${out#*-> }"
				out="${${out#\'}%\'}"
				# Beware of symlinks pointing to a relative path
				[[ "${out[1]}" = '/' ]] || out="$(dirname "$cmd")/$out"
				# Beware of potential empty element leading to print trailing
				# whitespace
				if (( $#full_cmd > 1)); then
					full_cmd=("$out" "${full_cmd[2,-1]}")
				else
					full_cmd=("$out")
				fi
				uniq_print "${full_cmd[@]}" # verbose is set
				old_cmd="$cmd"
				cmd="${full_cmd[1]}"
			done
		fi
	fi

	uniq_print "${full_cmd[@]}"
}

## Grep a keyword at the beginning of a line (ignoring whitespace) in a man page
mangrep() {
	if [[ $# -lt 2 ]]; then
		printf "usage:   mangrep <man page> <pattern> [<man flags>]\n" >&2
		printf "example: mangrep bash \"(declare|typeset)\"\n" >&2
		return 1
	fi
	local page="$1" pattern="$2"
	shift 2
	man -P "less -p \"^ *${pattern}\"" "$@" "${file}"
}

safe-remove() {
	[[ $# -gt 0 ]] || return 1
	[[ -e "$1" ]] || return 1

	sync
	if mount | grep -q "$1" && ! udisksctl unmount -b "$1"; then
		lsof "$1"
		return 1
	fi
	udisksctl power-off -b "/dev/${$(lsblk -no pkname "$1"):-${1#/dev/}}"
}

crypt-mount() {
	[[ $# -gt 0 ]] || return 1
	[[ -e "$1" ]] || return 1

	local name=crypt_"${1##*/}"
	sudo cryptsetup open "$1" "$name" || return 1
	udisksctl mount -b /dev/mapper/"$name" || return 1
	local mount_point="$(
		findmnt -lo SOURCE,TARGET \
			| grep -F /dev/mapper/"$name" \
			| awk '{ print $2; }'
	)"
	[[ -d $mount_point ]] && cd "$mount_point"
}

crypt-umount() {
	[[ $# -gt 0 ]] || return 1
	[[ -e "$1" ]] || return 1

	sync
	if
			mount | grep -q /dev/mapper/crypt_"${1##*/}" \
			&& ! udisksctl unmount -b /dev/mapper/crypt_"${1##*/}"
	then
		lsof /dev/mapper/crypt_"${1##*/}"
		return 1
	fi
	if ! sudo cryptsetup close crypt_"${1##*/}"; then
		sudo cryptsetup status crypt_"${1##*/}"
		return 1
	fi
	udisksctl power-off -b "$1"
}

if (( $+commands[trash] )); then
	## List items in trash if no argument is specified
	trash() {
		if (( ! $# )); then
			command trash-list
		else
			command trash "$@"
		fi
	}
fi

## Move one or more file(s) but keep a symlink to the new location.
mvln() {
	if (( # < 2 )); then
		printf "$0: missing file operand\n"
		return 1
	elif (( # == 2 )); then
		# When used for renaming only the dirname has to exist
		if [[ ! -d $(dirname "$2") ]]; then
			printf "$0: cannot move '$1' to '$2': No such file or directory\n"
			return 1
		fi
	elif [[ ! -d ${@[-1]} ]]; then
		printf "$0: target '${@[-1]}' is not a directory\n"
		return 1
	fi

	reg=0
	for file in "${@[1,-2]}"; do
		# If the target is a directory, `file` will end up in it
		# NOTE: We need absolute paths here for executions like `$0 foo/bar .`
		# TODO: When do we want/can we use relative links? Only when file is in
		# current dir?
		if [[ -d ${@[-1]} ]]; then
			target="${@[-1]:A}/$(basename "$file")"
		else
			target="${@[-1]:A}"
		fi
		if ! command mv -i "$file" "${@[-1]}"; then
			reg=1
			continue
		fi

		# NOTE: `ln` does not like trailing slashes on the last argument
		ln -s "$target" "${file%/}"
	done

	return $reg
}

## cd wrapper that when called without arguments, moves into the root of the
## current repo instead of HOME. (Except when already there)
cd() {
	if [[ $# -gt 0 ]]; then
		# Call `ls` on paths that end on '/ls' and don't exist with the suffix.
		# (When not properly pressing <CR>)
		if [[ ! -e ${@[-1]} && -e ${@[-1]%%/ls} ]]; then
			builtin cd "${@[1,-2]}" "${@[-1]%%ls}"
			pwd
			ls
		else
			builtin cd "$@"
		fi
		return
	fi

	local toplevel
	toplevel="$(git rev-parse --show-toplevel 2>/dev/null)"
	if (( $? )) || [[ $PWD = $toplevel ]]; then
		builtin cd
	else
		builtin cd "$toplevel"
	fi
}

# Commit, but put the last written commit message into the editor buffer.
# For this it uses .git/COMMIT_EDITMSG but deletes all lines after and including
# the first comment of the file.
# Useful for example when the commit-msg hook fails but only slight
# modifications are needed.
# Additional arguments (for example `-n` to bypass the hooks) can be passed.
git-commit-last-msg() {
	local gitdir
	gitdir="$(git rev-parse --git-dir)" || return
	git commit -eF <(sed -n '/^#/q;p' "$gitdir/COMMIT_EDITMSG") "$@"
}

nvim-man() {
	# Check for existence of man page. Assume that the page was specified as the
	# last argument.
	command man -w "${@[$#]}" >/dev/null || return

	if (( $+commands[nvim] )) && [[ $# -eq 1 ]]; then
		# $MANPAGER does the trick too but lines are hard-wrapped.
		nvim +"Man $1 | only"
	else
		command man "$@"
	fi
}

# Creates a git worktree checking it out the first argument in a temporary
# directory that is deleted again, if the spawned subshell exits.
git-checkout-worktree() {
	local GIT_ROOT TEMP_DIR REPO_DIR
	GIT_ROOT="$(basename "$(git rev-parse --show-toplevel)")" || return
	TEMP_DIR="$(mktemp -d)"
	REPO_DIR="$TEMP_DIR/$GIT_ROOT"

	git worktree add "$REPO_DIR" "$1"
	[[ -e "$REPO_DIR" ]] || return 1
	pushd -q "$REPO_DIR"

	# Start subshell
	"$SHELL"

	# Cleanup when exiting
	popd -q

	# Restart the subshell until every issue is resolved and the worktree is
	# removed
	until [[ ! -e "$REPO_DIR" ]] || git worktree remove "$REPO_DIR"; do
		pushd -q "$REPO_DIR"
		"$SHELL"
		popd -q
	done

	git worktree prune
	command rm -rf "$TEMP_DIR"
}

# This is meant for adding a quick fix to a commit.
# It automatically rebases a given commit (defaults to HEAD), applies the given
# stash (defaults to last) and finishes the rebase.
git-rebase-add-stash() {
	: ${1:=HEAD~}
	[[ "$(git cat-file -t "$1")" = "commit" ]] || return 1
	(( $(git stash list | wc -l) )) || { echo "No stashes" >&2; return 1; }

	# Substitute the first 'pick' with 'edit' in the rebase todo, apply the
	# stash & finish
	EDITOR='sed -i "1s/^pick/edit/"' \
		git rebase -i "$1" &&
		git stash apply "${2:-0}" &&
		git add -u &&
		git rebase --continue
}

# Create copy with a .bkp extension
bkp() {
	for f; do
		command cp -i "$f"{,.bkp}
	done
}

# Reverse bkp()
unbkp() {
	for f; do
		if [[ ${f%.bkp} != $f ]]; then
			command mv -i "$f" "${f%.bkp}"
		elif [[ -e $f.bkp ]]; then
			command mv -i "$f.bkp" "$f"
		fi
	done
}
