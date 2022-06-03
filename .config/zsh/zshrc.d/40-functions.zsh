## Author:  druckdev
## Created: 2019-08-28

# Compares two pdfs based on the result of pdftotext
pdfdiff() {
	if [[ $# -eq 2 && -r "$1" && -r "$2" ]]; then
		diff <(pdftotext "$1" -) <(pdftotext "$2" -)
	else
		echo "something went wrong" 2>&1
		return 1
	fi
}

# Gets Passwd from bitwarden and copies it into the clipboard
bwpwd() {
	if bw "get" "password" "$@" >/dev/null; then
		bw "get" "password" "$@" | tr -d '\n' | setclip
	else
		bw "get" "password" "$@"
	fi
}

# creates directory and changes into it
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

# Encode and decode qr-codes
qr() {
	if [[ $# -eq 1 && -r "$1" ]]; then
		zbarimg "$1"
	else
		qrencode "$@"
	fi
}

# Edit config file
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

# Change into config dir
c() {
	CONF_DIR="$(_get_config_dir $*)"
	if [[ $? -eq 0 ]]; then
		cd "$CONF_DIR"
	else
		printf "$CONF_DIR" >&2
		return 1
	fi
}
# Get config directory
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

# Function that resolves a command to the end
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

# Grep a keyword at the beginning of a line (ignoring whitespace) in a man page
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

crypt-open() {
	emulate -L zsh -o err_return -o pipe_fail
	[[ $# -gt 0 ]]
	[[ -b "$1" ]]

	local name mount_point
	name=crypt_"${1:t}"

	sudo cryptsetup open "$1" "$name"
	udisksctl mount -b /dev/mapper/"$name"

	mount_point="$(
		findmnt -lo SOURCE,TARGET \
			| grep -F /dev/mapper/"$name" \
			| awk '{ print $2; }'
	)"
	[[ -d $mount_point ]] && cd "$mount_point"

	# create link in $HOME/mounts
	[[ ! -e "$HOME/mounts/${mount_point:t}" ]] \
		|| { echo "~/mounts/${mount_point:t} exists" >&2; return 1; }
	mkdir -p ~/mounts/
	ln -s "$mount_point" ~/mounts/
}

crypt-close() {
	emulate -L zsh -o err_return -o pipe_fail
	[[ $# -gt 0 ]]
	[[ -b "$1" ]]

	sync

	local name mount_point
	name=crypt_"${1:t}"
	mount_point="$(
		findmnt -lo SOURCE,TARGET \
			| grep -F /dev/mapper/"$name" \
			| awk '{ print $2; }'
	)"

	if
			mount | grep -q /dev/mapper/"$name" \
			&& ! udisksctl unmount -b /dev/mapper/"$name"
	then
		lsof /dev/mapper/"$name"
		return 1
	fi
	if ! sudo cryptsetup close "$name"; then
		sudo cryptsetup status "$name"
		return 1
	fi
	udisksctl power-off -b "$1"

	rm ~/mounts/"${mount_point:t}" \
	&& rmdir --ignore-fail-on-non-empty ~/mounts/ \
	|| echo "~/mounts/${mount_point:t} did not exist"
}

if (( $+commands[trash] )); then
	# List items in trash if no argument is specified
	trash() {
		if (( ! $# )); then
			command trash-list
		else
			command trash "$@"
		fi
	}
fi

# Move one or more file(s) but keep a symlink to the new location.
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

# cd-wrapper that recognizes a trailing `ls` behind the path (When not properly
# pressing <CR>)
cd() {
	# Call `ls` on paths that end on '/ls' and don't exist with the suffix.
	# (When not properly pressing <CR>)
	if [[ ! -e ${@[-1]} && -e ${@[-1]%%/ls} ]]; then
		builtin cd "${@[1,-2]}" "${@[-1]%%ls}"
		pwd
		ls
	else
		builtin cd "$@"
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
	# Use nvim only if it exists, there was just one argument passed, that
	# argument is not an option (e.g. `--version`) and stdout is a terminal.
	if (( $+commands[nvim] && $# == 1 )) && [[ $1 == ${1#-} && -t 1 ]]; then
		# Check for existence of man page.
		command man -w "$1" >/dev/null || return

		# $MANPAGER would do the trick too but lines would be hard-wrapped.
		nvim -u NORC +"
			runtime! plugin/man.vim |
			Man $1 |
			only |
			set scrolloff=999 |
			normal M
		"
	else
		command man "$@"
	fi
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

# Display the log for the staged files (excluding additions, as they do not have
# a history and I prefer the full log instead of nothing in that case).
git-log-staged-files() {
	# No quotes around the filename expansion as they are only field splitted on
	# newlines anyway and `git log -- ""` complains with:
	#
	#     fatal: empty string is not a valid pathspec.
	#
	# As the `git-diff` command can return nothing, this is important.
	#
	# NOTE: Use `log.follow` instead of `--follow` to support multiple arguments
	git -c log.follow log --name-only "$@" -- \
		${(f)"$(git diff --name-only --cached --diff-filter=a)"}
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

# Create a virtual environment for python including a .envrc that loads the venv
create_venv() {
	[[ ! -e venv ]] || return 0
	python -m venv venv
	if (( $+commands[direnv] )); then
		ln -s ~/.local/share/direnv/templates/python-venv.envrc .envrc
		direnv allow
	fi
}

# Open READMEs in a pager when going into a directory that contains one.
# See 45-hooks.zsh
_page_readme_chpwd_handler() {
	local readme
	local -a readmes=(README.md README.txt README Readme.md Readme.txt Readme
	                  readme.md readme.txt readme)

	for readme in "$readmes[@]"; do
		[[ -e "$readme" ]] || continue

		${PAGER:-less} "$readme"
		break
	done
}

# Improved pgrep
# I sometimes find `pgrep` not matching the processes I am searching for, but
# `ps aux | grep ...` did not disappoint yet.
pgrep() {
	# Fall back to real `pgrep` if options are specified. I have no interest in
	# emulating `pgrep` features with `ps` and other tools. This function is
	# only meant for quick searches
	if (( $# > 1 )); then
		command pgrep "$@"
		return
	fi

	# - Set EXTENDED_GLOB for the `b` globbing flag.
	# - Set UNSET so that no arguments can be specified leading to `grep ""`
	#   matching everything, as `ps aux` without pipe would be my desired
	#   behavior.
	emulate -L zsh -o extendedglob -o unset

	# Substitute the captured first character with itself surrounded by
	# brackets. The `(#b)` turns on backreferences, storing the match in the
	# array $match (in this case with only one element).
	# So for example: "pattern" -> "[p]attern"
	# This has the effect that the `grep` does not grep itself in the processes
	# list.
	ps aux | grep "${1/(#b)(?)/[$match]}"
}

# Use shellcheck.net if shellcheck is not installed.
shellcheck() {
	if (( $+commands[shellcheck] )); then
		command shellcheck "$@"
		return
	fi

	printf >&2 \
		"Using www.shellcheck.net. You might want to install shellcheck.\n\n"
	local url json_parser arg

	url='https://www.shellcheck.net/shellcheck.php'
	json_parser="${${commands[jq]:-cat}:c}"

	for arg; do
		if [[ ! -r $arg ]]; then
			printf "%s\n" "$arg: File does not exist or is non-readable" >&2
			continue
		fi
		curl -sS "$url" -X POST --data-urlencode script@"$arg" \
		| "$json_parser"
	done
}

# Find files that end with one of multiple given suffixes.
#
# Usage:
# suffix sfx... [-- path...]
#
# `sfx` is given to `find` in the form `-name "*$sfx"`.
# `path` is given as starting point to `find`, defaulting to `.`.
suffix() {
	if (( ! $+commands[find] )); then
		printf >&2 "find not installed\n"
		return 1
	fi

	local i=1
	for arg; do
		[[ $arg != "--" ]] || break
		: "$((i++))"
	done
	# NOTE: if "--" is not included in $@, i will be greater than $#, and no
	# starting point is passed to `find`, which then defaults to `.`.

	local -a names
	# Take everything before "--" and quote special characters
	names=( "${(@q)@:1:$((i-1))}" )
	# Prepend an `*` to every element and quote the result
	names=( "${(@)names//(#b)(*)/\"*$match\"}")
	# Join with " -o -name " and then split again using shell parsing
	names=( "${(@zj: -o -name :)names}" )
	# Pass starting points and the names after removing one level of quotes
	find "${@:$((i+1))}" -name "${(@Q)names}"
}
