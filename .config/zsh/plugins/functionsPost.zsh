## Author:  druckdev
## Created: 2019-10-27 (originally 2019-08-28 as functions.zsh)

## change into dir and print accordingly
function cl() {
	cd "$@" && ls
}

## Copy file and append .bkp extension
function bkp() {
	for file in "$@"; do
		cp -i "$file" "$file.bkp"
	done
}

## Launches program and detaches it from the shell
function launch() {
	# eval "$@" ## does not work with special characters?
	launch_command="$1"
	shift
	$launch_command "$@" &>/dev/null & disown
}

## Compares two pdfs based on the result of pdftotext
function pdfdiff() {
	if [[ $# -eq 2 && -r "$1" && -r "$2" ]]; then
		diff <(pdftotext "$1" -) <(pdftotext "$2" -)
	else
		echo "something went wrong" 2>&1
		return 1
	fi
}

## Gets Passwd from bitwarden and copies it into the clipboard
function bwpwd() {
	if bw "get" "password" "$@" >/dev/null; then
		bw "get" "password" "$@" | tr -d '\n' | setclip
	else
		bw "get" "password" "$@"
	fi
}

## creates directory and changes into it
function mkcd () {
	# Create directory
	mkdir "$@"
	# shift arguments if mkdir options were used
	while [ $# -gt 1 ]; do
		shift
	done
	if [ -d "$1" ]; then
		cd "$1"
		pwd
	fi
}

## Send a message over telegram by using the -e flag
function msg() {
	if [ $# -ge 2 ]; then
		telegram-cli -W -e "msg $*" | grep -E "${${*/ /.*}//_/ }"
		                          # | grep -E "$(echo "$*" | sed 's/ /.*/; s/_/ /g')"
	else
		printf "\033[1;31mPlease specify a contact and a message.\n\033[0m" >&2
	fi
}

## Execute tg -e command but cuts of the uninteresting parts
function tg() {
	tg="telegram-cli"
	if [ "$1" = "-e" ]; then
		shift
		$tg -N -W -e "$@" | tail -n +9 | head -n -2
	else
		$tg -N -W "$@"
	fi
}

## Encode and decode qr-codes
function qr() {
	if [[ $# -eq 1 && -r "$1" ]]; then
		zbarimg "$1"
	else
		qrencode "$@"
	fi
}

## Edit config file
function conf() {
	# default to vim if no editor is set
	local CONF_EDITOR=${EDITOR:-vim}

	# parse otions
	while getopts "e:" opt 2>/dev/null; do
		case $opt in
			e) CONF_EDITOR="$OPTARG";;
			*) printf "\033[1;31mUsage: $0 [-e <editor>] <program>[/subdirs] [<config_file>]\n\033[0m" >&2
			   return 1 ;;
		esac
	done
	shift $(($OPTIND - 1 ))

	# CONF_EDITOR=( $(resolve -s $CONF_EDITOR) )

	# conf needs an argument
	if [ $# -eq 0 ]; then
		printf "\033[1;31mPlease specify a config.\n\033[0m" >&2
		return 1
	fi
	# search for program name in XDG_CONFIG_HOME and $HOME
	local CONF_DIR="$(_get_config_dir "$1")"
	if [ $? -ne 0 ]; then
		printf "\033[1;31mFalling back to $HOME.\n\033[0m" >&2
		CONF_DIR="$HOME"
	fi

	# open file with specified name if
	if [ $# -gt 1 ]; then
		if [ -r "$CONF_DIR/$2" ]; then
			$CONF_EDITOR "$CONF_DIR/$2"
			return 0
		else
			printf "\033[1;31mCould not find config file with that name.\n\033[0m" >&2
			return 1
		fi
	fi

	# possible config-file names + same in hidden
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
		if [ -r "$CONF_DIR/$config" ]; then
			$CONF_EDITOR "$CONF_DIR/$config"
			return 0
		elif [ -r "$CONF_DIR/.$config" ]; then
			$CONF_EDITOR "$CONF_DIR/.$config"
			return 0
		fi
	done

	# if no config was found in a location other than HOME, look again in HOME.
	# (For cases like default vim with ~/.vim/ and ~/.vimrc)
	if [ "$CONF_DIR" != "$HOME" ];then
		for config in $CONF_PATTERNS; do
		# Only look for hidden files
		if [ -r "$HOME/.$config" ]; then
			$CONF_EDITOR "$HOME/.$config"
			return 0
		fi
		done
	fi

	printf "\033[1;31mCould not find config file.\n\033[0m" >&2
	return 1
}

## Change into config dir
function c() {
	CONF_DIR="$(_get_config_dir $*)"
	if [ $? -eq 0 ]; then
		cd "$CONF_DIR"
	else
		printf "$CONF_DIR" >&2
		return 1
	fi
}
## Get config directory
function _get_config_dir() {
	if [ $# -gt 1 ]; then
		printf "\033[1;31mPlease specify one config.\n\033[0m" >&2
		return 1
	elif [ $# -eq 0 ]; then
		echo "${XDG_CONFIG_HOME:-$HOME/.config}"
	elif [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/$1" ]; then
		echo "${XDG_CONFIG_HOME:-$HOME/.config}/$1"
	elif [ -d "$HOME/.$1" ]; then
		echo "$HOME/.$1"
	else
		printf "\033[1;31mCould not find config home.\n\033[0m" >&2
		return 1
	fi
}

## Function that resolves a command to the end
function resolve() {
	# TODO: comment!!
	# In script mode only the result and its arguments are printed
	# The result can then be used directly by other scripts without further
	# manipulation
	typeset SCRIPT_MODE VERBOSE_MODE 1>&2
	while getopts "sv" opt 2>/dev/null; do
		case $opt in
			s)  SCRIPT_MODE=1;;
			v)  VERBOSE_MODE=1;;
			*)  echo "Unknown flag!" >&2
				return 1;;
		esac
	done
	shift $(( $OPTIND - 1 ))

	if (( $SCRIPT_MODE )) && (( $VERBOSE_MODE )); then
		echo "Script and verbose mode do no work together." >&2
		return 1
	fi

	typeset THIS THIS_COMMAND THIS_ARGUMENTS 1>&2
	# When receiving a command with arguments, do not differ between
	# one and multiple arguments.
	THIS="$*"
	THIS_COMMAND="${THIS%% *}"
	# ${THIS%%* } would result in THIS_COMMAND when no arguements are specified.
	# We want an empty string in this case.
	THIS_ARGUMENTS="${THIS#${THIS_COMMAND}}"

	# Resolve all aliases
	while [[ "$(which $THIS_COMMAND | head -n1)" =~ "^${THIS_COMMAND}: aliased to " ]]; do
		if (( $VERBOSE_MODE )); then
			echo $THIS_COMMAND$THIS_ARGUMENTS
		fi
		THIS="$(which "$THIS_COMMAND" | cut -d' ' -f4-)"
		THIS_COMMAND="${THIS%% *}"
		THIS_ARGUMENTS="${THIS#${THIS_COMMAND}}$THIS_ARGUMENTS"

	done

	command_type="$(type $THIS_COMMAND)"
	if [[ "$command_type" =~ "^$THIS_COMMAND is a shell function from " ]]; then
		if (( $SCRIPT_MODE )); then
			echo -n "$THIS_COMMAND$THIS_ARGUMENTS"
			return 0
		elif (( $VERBOSE_MODE )); then
			echo "$THIS_COMMAND$THIS_ARGUMENTS"
		else
			echo "$* is resolved to:\n$THIS_COMMAND$THIS_ARGUMENTS"
		fi
		echo -n "${command_type}:"
		from_file="$(echo $command_type | cut -d' ' -f7-)"
		# from_file=${command_type##* }
		grep -En -m1 "(function[ \t]+${THIS_COMMAND}[ \t]*(\(\)|)[ \t]*{|${THIS_COMMAND}[ \t]*\(\)[ \t]*{)" "$from_file" \
			| cut -d: -f1
	else
		if (( $VERBOSE_MODE )); then
			echo "$THIS_COMMAND$THIS_ARGUMENTS"
		fi
		THIS_COMMAND="$(which $THIS_COMMAND)"
		if [ $? -ne 0 ]; then
			echo "${THIS_COMMAND%% *} not found." >&2
			return 1
		fi
		if (( $VERBOSE_MODE )); then
			echo -n "$THIS_COMMAND"
			NEXT_STEP="$(file -bh $THIS_COMMAND | cut -d' ' -f4-)"
			if [ "${NEXT_STEP:0:1}" != '/' ]; then
				NEXT_STEP="${THIS_COMMAND%/*}/$NEXT_STEP"
			fi
			while [[ "$(file -bh $THIS_COMMAND)" =~ "^symbolic link to" && "$NEXT_STEP" != "$THIS_COMMAND" ]]; do
				THIS_COMMAND=$NEXT_STEP
				NEXT_STEP="$(file -bh $THIS_COMMAND | cut -d' ' -f4-)"
				if [ "${NEXT_STEP:0:1}" != '/' ]; then
					NEXT_STEP="${THIS_COMMAND%/*}/$NEXT_STEP"
				fi

				echo -n "\n$THIS_COMMAND"
			done
			echo $THIS_ARGUMENTS
			return 0
		fi
		THIS_COMMAND="$(realpath $THIS_COMMAND)"
		if (( $SCRIPT_MODE )); then
			echo -n "$THIS_COMMAND$THIS_ARGUMENTS"
			return 0
		fi
		echo "$* is resolved to:\n$THIS_COMMAND$THIS_ARGUMENTS"
	fi
}

## Grep a keyword at the beginning of a line (ignoring whitespace) in a man page
function mangrep() {
	mangrep_file="$1"
	mangrep_pattern="$2"
	shift
	shift
	man -P 'less -p "^ *'"${mangrep_pattern}\"" "$@" "${mangrep_file}"
	unset mangrep_{file,pattern}
}

## Grep in zsh history file
function histgrep() {
	grep "$@" "${HISTFILE:-$HOME/.zsh_history}"
}

function format() {
	# TODO: respect manual changes made in meld
	CLANG_FORMAT_FILE="$HOME/Projects/C/.clang.format"
	FORMAT="{$(sed -E '/^\s*$/d' "$CLANG_FORMAT_FILE" | tr '\n' ',' | sed 's/,$//')}"
	if [ $# -eq 1 ]; then
		meld <(clang-format -style="$FORMAT" $1) $1
	fi
	echo -n "Are you happy? [yn] "
	read yn
	if [ $yn = "y" ]; then
		clang-format -i -style="$FORMAT" $1
	fi
}

function urlenc() {
	python3 -c "from urllib import parse; print(parse.quote('$@'), end='')"
}

function urldec() {
	python3 -c "from urllib import parse; print(parse.unquote('$@'), end='')"
}

glog() {
	# Return if not in git repo
	git rev-parse || return

	# One line format for fzf list view
	# abbreviated commit hash (yellow), title and ref names
	local formatshort='--pretty=format:%C(yellow)%h %Creset%s%C(auto)%d'
	# Verbose format for the preview window on the right
	# This array is stitched together with newlines later
	local format=(
		'--pretty=format:%C(yellow)'     # newline created by this eaten by %-
		'%-commit: %H%C(auto)'           # yellow commit hash
		'%-D%Cblue'                      # auto colored ref names (if any)
		'Author:     %aN %aE%Cred'       # blue author mail
		'AuthorDate: %ad%Cblue'          # red author date
		'Commit:     %cN %cE%Cred'       # blue commiter mail
		'CommitDate: %cd%Creset%C(bold)' # red commit date
		''
		'    %s%Creset'                  # bold white subject
		' ' # space is here so that the empty line is not eaten when no body
		'%-b'                            # body
		'--------------------------------------------------'
		''
	)

	# Before being able to operate on the string itself we need to remove all
	# ansi color escape sequences to not confuse sed.
	local del_ansi='s/\[[0-9]{0,2}m//g'
	# Ignore the graph part at the beginning, then capture the commit hash and
	# throw away the rest of the line.
	local commit_hash='s/^[ */\\|]*([a-z0-9]*).*$/\1/'

	local dateshort='--date=format:%F' # year
	local date='--date=format:%F %T %z' # year time timezone
	local colors='--color=always'
	local binds=(
		'ctrl-space:toggle-preview'
		'ctrl-j:preview-down'
		'ctrl-k:preview-up'
	)

	# Display a colorful ascii graph of the commits in the above format and pipe
	# that into fzf.
	# Display ansi colors, reverse the layout so that the newest commit is at
	# the top, and add a preview command, that:
	# Takes the commit line, extracts the commit hash by using both patterns
	# from above and saves that in a variable. When the variable is not empty
	# (we are not on a line that contains only graph elements), execute git-show
	# on the commit hash.
	commit="$(\
		git log "$formatshort" --graph "$dateshort" "$colors" \
		| fzf --ansi --reverse --bind "${(j:,:)binds}" --preview="
			out=\"\$(echo {} | sed -Ee \"$del_ansi\" -e \"$commit_hash\")\"
			if [ \"\$out\" ]; then
				git show \"${(j:%n:)format}\" \"$date\" $colors \"\$out\"
			fi
		"
	)"
	# If fzf exits successfully, put the abbreviated commit hash into the
	# clipboard and write it into stdout.
	if ! (( $? )); then
		commit="$(sed -Ee "$del_ansi" -e "$commit_hash" <<<"$commit")"
		if command -v xclip &>/dev/null; then
			echo -n "$commit" | xclip -selection clip
		fi
		echo "$commit"
	fi
}

safe-remove() {
	[ $# -gt 0 ] || return 1
	[ -e "$1" ] || return 1

	sync
	if ! udisksctl unmount -b "$1"; then
		lsof "$1"
		return 1
	fi
	udisksctl power-off -b "/dev/$(lsblk -no pkname "$1")"
}
