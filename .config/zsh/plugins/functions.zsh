## Author:  druckdev
## Created: 2019-08-28

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
	while [[ $# -gt 1 ]]; do
		shift
	done
	if [[ -d "$1" ]]; then
		cd "$1"
		pwd
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
	local CONF_EDITOR
	if [[ -n "$EDITOR" ]]; then
		CONF_EDITOR="$EDITOR"
	elif command -v vim &>/dev/null; then
		CONF_EDITOR=vim
	elif command -v nano &>/dev/null; then
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
function c() {
	CONF_DIR="$(_get_config_dir $*)"
	if [[ $? -eq 0 ]]; then
		cd "$CONF_DIR"
	else
		printf "$CONF_DIR" >&2
		return 1
	fi
}
## Get config directory
function _get_config_dir() {
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
		if [[ $? -ne 0 ]]; then
			echo "${THIS_COMMAND%% *} not found." >&2
			return 1
		fi
		if (( $VERBOSE_MODE )); then
			echo -n "$THIS_COMMAND"
			NEXT_STEP="$(file -bh $THIS_COMMAND | cut -d' ' -f4-)"
			if [[ "${NEXT_STEP:0:1}" != '/' ]]; then
				NEXT_STEP="${THIS_COMMAND%/*}/$NEXT_STEP"
			fi
			while [[ "$(file -bh $THIS_COMMAND)" =~ "^symbolic link to" && "$NEXT_STEP" != "$THIS_COMMAND" ]]; do
				THIS_COMMAND=$NEXT_STEP
				NEXT_STEP="$(file -bh $THIS_COMMAND | cut -d' ' -f4-)"
				if [[ "${NEXT_STEP:0:1}" != '/' ]]; then
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
	if ! udisksctl unmount -b "$1"; then
		lsof "$1"
		return 1
	fi
	udisksctl power-off -b "/dev/$(lsblk -no pkname "$1")"
}

crypt-mount() {
	[[ $# -gt 0 ]] || return 1
	[[ -e "$1" ]] || return 1

	sudo cryptsetup open "$1" crypt_"${1##*/}" || return 1
	udisksctl mount -b /dev/mapper/crypt_"${1##*/}"
}

crypt-umount() {
	[[ $# -gt 0 ]] || return 1
	[[ -e "$1" ]] || return 1

	sync
	if ! udisksctl unmount -b /dev/mapper/crypt_"${1##*/}"; then
		lsof /dev/mapper/crypt_"${1##*/}"
		return 1
	fi
	if ! sudo cryptsetup close crypt_"${1##*/}"; then
		sudo cryptsetup status crypt_"${1##*/}"
		return 1
	fi
	udisksctl power-off -b "$1"
}

## List items in trash if no argument is specified
function trash() {
	if (( ! $# )); then
		command trash-list
	else
		command trash "$@"
	fi
}

## Open nemo in current directory if no argument is specified
function nemo() {
	if (( ! $# )); then
		command nemo .
	else
		command nemo "$@"
	fi
}
