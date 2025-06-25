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

# mkdir wrapper that changes into the created directory if only one was given
mkcd () {
	# Create directory
	command mkdir "$@" || return

	# Remove flags and their arguments
	nargs="$#"
	for ((i = 0; i < nargs; i++)); do
		if [[ ${1[1]} != '-' || $1 = '-' ]]; then
			# Skip all non-flags
			set -- "${@:2}" "$1"
		else
			# When `-m` is given, shift it's MODE argument as well
			! [[ $1 =~ ^-([^-].*)?m$ ]] || { shift; i+=1 }

			# Stop the loop on `--`
			[[ $1 != '--' ]] || { shift; break }

			shift
		fi
	done

	# cd into the created directory if only one was specified
	[[ $# -eq 1 && -d $1 ]] || return 0

	# append a slash to change into the new directory instead of back to the
	# last visited one
	[[ $1 != '-' ]] || 1='-/'

	cd "$1"
	pwd
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
	# EXTENDED_GLOB needed for /#
	emulate -L zsh -o extendedglob

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

	# remove trailing slashes. needs extendedglob
	1="${1%%/#}"

	# search for program name in XDG_CONFIG_HOME and $HOME
	local CONF_DIR
	if ! CONF_DIR="$(_get_config_dir "$1")"; then
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
		# when looking in HOME, skip entries of CONF_PATTERNS, if they
		# do not start with the given program name (i.e. they are
		# generic)
		[[ $CONF_DIR != $HOME || ${config#$1} != $config ]] || continue

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
			# skip entries of CONF_PATTERNS, if they do not start
			# with the given program name (i.e. they are generic)
			[[ ${config#$1} != $config ]] || continue

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

# Move one or more file(s) but keep a symlink to the new location. Pass `-r` to
# create a relative symlink.
# TODO: suppot `--` argument
mvln() {
	local flags='-s'
	if [[ $1 = '-r' ]]; then
		flags+='r'
		shift
	fi

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

	local file reg=0
	for file in "${@[1,-2]}"; do
		# NOTE: We need absolute paths here for executions like `$0 foo/bar .`
		# TODO: When do we want/can we use relative links? Only when file is in
		# current dir?
		target="${@[-1]:A}"
		# If the target is a directory, `file` will end up in it
		[[ ! -d ${@[-1]} ]] || target+="/$file:t"

		if ! command mv -i "$file" "${@[-1]}"; then
			reg=1
			continue
		fi

		# NOTE: `ln` does not like trailing slashes on the last argument
		ln "$flags" "$target" "${file%/}"
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

# I sometimes find `pgrep` not matching the processes I am searching for, but
# `ps aux | grep ...` did not disappoint yet.
psgrep() {
	# - Set EXTENDED_GLOB for the `b` globbing flag.
	emulate -L zsh -o extendedglob

	# print column info
	ps u | head -1

	for arg; do
		# Pass to grep directly if it looks like a regex
		if [[ "$arg" =~ '[][$|.*?+\\()^]' ]]; then
			ps aux | grep -E "$arg"
			continue
		fi

		# Substitute the captured first character with itself surrounded by
		# brackets. The `(#b)` turns on backreferences, storing the match in the
		# array $match (in this case with only one element).
		# So for example: "pattern" -> "[p]attern"
		# This has the effect that the `grep` does not grep itself in the processes
		# list.
		ps aux | grep "${arg/(#b)(?)/[$match]}"
	done
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
	local cmd
	if (( $+commands[bfs] )); then
		cmd=bfs
	elif (( $+commands[find] )); then
		cmd=find
	else
		printf >&2 "Neither bfs nor find installed\n"
		return 1
	fi

	local i=${@[(ei)--]}
	# NOTE: if "--" is not included in $@, i will be greater than $#, and no
	# starting point is passed to `find`, which then defaults to `.`.

	local -a names
	# Take everything before "--" and quote special characters
	names=( "${(@q)@:1:$((i-1))}" )
	# Prepend an `*` to every element
	names=( "${(@)names//#/*}" )
	# Join with " -o -name " and then split again using shell parsing
	names=( "${(@zj: -o -name :)names}" )
	# Pass starting points and the name arguments
	"$cmd" "${@:$((i+1))}" -name "${(@)names}"
}

# Find duplicate files
finddup() {
	# find all files, filter the ones out with unique size, calculate md5 and
	# print duplicates. Assumes that no file contains tab characters in their
	# name.
	#
	# TODO: Use cksum to calculate faster CRC with custom awk solution to print
	#       duplicates, as `uniq -w32` breaks through the different CRC lengths.
	# TODO: The second sort call could be optimized in some way, since we
	#       already grouped files with the same size. Instead of resorting the
	#       whole thing, we only need to check if the files with the same size
	#       have the same hash. Just removing the sort call does almost the
	#       trick just breaks for groups of files with the same size where same
	#       checksums are not behind each other.

	find "$@" -type f -exec du -b '{}' '+' \
	| awk -F'\t' '{print $2"\t"$1}' \
	| sort --field-separator=$'\t' -nk2 \
	| uniq -f1 -D \
	| cut -d$'\t' -f1 \
	| xargs -d'\n' md5sum \
	| sort -k1,1 \
	| uniq -w32 --all-repeated=separate \
	| cut -d' ' -f3-
}

# Wrapper around tmsu that searches for .tmsu/db in all parent directories and
# fallbacks to XDG_DATA_HOME if not found.
tag() {
	if (( ! $+commands[tmsu] )); then
		printf >&2 "tmsu not installed.\n"
		return 1
	fi

	local db dir="$PWD" std=".tmsu/db"

	# Go up directories until root to find .tmsu/db
	until [[ -e $dir/$std || $dir = / ]]; do
		dir="${dir:h}"
	done
	db="$dir/$std"

	# Fallback to XDG_DATA if .tmsu/db was not found in one of the parent dirs.
	if [[ ! -e $db ]]; then
		db="${XDG_DATA_HOME:-$HOME/.local/share}"/tmsu/db
		mkdir -p "${db:h}"
	fi

	env TMSU_DB="$db" tmsu "$@"
}

# Display the help for a given python module/function/etc. Try to guess when
# something needs an import.
pyhelp() {
	local py_exec import_statement

	if (( $+commands[python] )); then
		py_exec=python
	elif (( $+commands[python3] )); then
		py_exec=python3
	elif (( $+commands[python2] )); then
		py_exec=python2
	else
		print >&2 "Python not installed."
		return 1
	fi

	for arg; do
		import_statement=
		if [[ $arg =~ '^([^.]*)\.' ]]; then
			import_statement="import $match[1]; "
		fi

		$py_exec -c "${import_statement}help($arg)"
	done
}

# A small wrapper that tries to prevent an overwrite of an existing file when
# forgetting to specify the destination-file.
pdfunite() {
	if [[ -e "$@[-1]" ]]; then
		print >&2 "Destination-file exists already!"
		return 2
	fi

	command pdfunite "$@"
}

# List pids of processes that use an open file
psofof() {
	lsof "$@" | tail -n +2 | awk '{ print $2 }' | sort -u
}

# diff the output of multiple commands following the same pattern. For each
# argument behind `--`, the template-command will be executed after replacing
# the placeholder `%%` with the argument. If no placeholder is given, the
# argument will be placed at the end. Pipelines can be executed by
# quoting/escaping the pipes.
#
# Uses vimdiff if it is installed and EDITOR or VISUAL are matching `vi` or if
# more than 2 arguments were passed.
#
# Example:
#     diffcmds cat -n %% '|' head -5 -- file1 file2
# would run:
#     vimdiff =(cat -n file1 | head -5) =(cat -n file2 | head -5)
#
# or simply:
#     diffcmds xxd -- file1 file2
# for:
#     vimdiff =(xxd file1) =(xxd file2)
diffcmds() {
	# TODO: Support own arguments for example to switch the placeholder or the
	#       diffcmd
	# TODO: Find better way to dequote pipes. (e.g. `%|` to use a pipe?)
	local i arg ps_sub
	local -a template args final_cmd

	local diff_cmd="$diff_cmd"
	if [[ -n $diff_cmd ]]; then
		# already set by caller
	elif (( $+commands[vimdiff] && ! $+commands[diff] )); then
		diff_cmd=vimdiff
	elif (( $+commands[diff] && ! $+commands[vimdiff] )); then
		diff_cmd=diff
	elif (( $+commands[diff] && $+commands[vimdiff] )); then
		if [[ $EDITOR =~ vi || $VISUAL =~ vi ]]; then
			diff_cmd=vimdiff
		else
			diff_cmd=diff
		fi
	else
		printf >&2 "Neither diff nor vimdiff installed\n"
		return 1
	fi

	# Get index of last `--` occurrence
	i=$(( # - ${${(aO)@}[(ei)--]} + 1 ))
	if (( i >= # || i < 2 )); then
		printf >&2 "%s\n" "Usage: $0 CMD [ARG...] [%%] [ARG...] -- ARG..."
		return 1
	fi

	# Quote special characters and split into arrays
	set -- "${(q@)@}"
	template=( "${@:1:$((i-1))}" )
	args=("${@:$((i+1))}")
	# Unquote standalone pipes
	template=( "${(@)template/#%\\|/|}" )

	# Place arguments at the back if no position was supplied with `%%`
	[[ "$template[@]" =~ '%%' ]] || template+='%%'

	# Just execute the command without *diff if there is only one argument
	if (( i + 1 == # )); then
		eval "${(@)template//\%\%/$args[-1]}"
		return
	fi

	# Fallback or abort if more than 2 arguments were supplied to `diff`
	if [[ $diff_cmd = diff ]] && (( $#args > 2 )); then
		printf >&2 "Too many arguments for diff."
		if (( $+commands[vimdiff] )); then
			printf >&2 " Using vimdiff.\n"
			diff_cmd=vimdiff
		else
			printf >&2 "\n"
			return 1
		fi
	fi

	# NOTE: `=()` is necessary since vim might seek the file. See zshexpn(1)
	[[ $diff_cmd = vimdiff ]] && ps_sub='=' || ps_sub='<'

	final_cmd=("$diff_cmd")
	for arg in "$args[@]"; do
		# Substitute placeholder and wrap in process substitution
		final_cmd+=( "$ps_sub(${(@)template//\%\%/$arg})" )
	done
	eval "$final_cmd[@]"
}

# Allow to delete current working dir
rmdir() {
	emulate -L zsh

	if (( $# == 1 )) && [[ $1 == '.' ]]; then
		to_del="$PWD"
		pushd -q ..
		command rmdir "$to_del" || popd -q
	else
		command rmdir "$@"
	fi
}

# bfs wrapper with condensed output by default (i.e. no directories except if
# they're empty)
(( ! $+commands[bfs] )) || bfs() {
	emulate -L zsh

	# Make sure that std{out,err} are associated with a tty and that no
	# arguments were passed that start with a dash
	if [[ -t 1 && -t 2 ]] && (( ! $# || ! ${@[(I)-*]} )); then
		# Exclude non-empty directories
		command bfs "$@" -type d -not -empty -o -print
	else
		command bfs "$@"
	fi
}

# TODO: bring together with bfs
# find wrapper with condensed output by default (i.e. no directories except if
# they're empty)
(( ! $+commands[find] )) || find() {
	emulate -L zsh

	# Make sure that std{out,err} are associated with a tty and that no
	# arguments were passed that start with a dash
	if [[ -t 1 && -t 2 ]] && (( ! $# || ! ${@[(I)-*]} )); then
		# Exclude non-empty directories and mark empty ones with a slash
		command find "$@" -type d \( -not -empty -o -printf "%p/\n" \) -o -print
	else
		command find "$@"
	fi
}
