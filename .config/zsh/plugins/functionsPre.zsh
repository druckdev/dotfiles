## Author:  druckdev
## Created: 2019-10-27 (originally 2019-08-28 as functions.zsh)

## List items in trash if no argument is specified
function _trash_list_default() {
	if [ $# -eq 0 ]; then
		command trash-list
	else
		command trash "$@"
	fi
}

## Open nemo in current directory if no argument is specified
function _nemo_wd_default() {
	if [ $# -eq 0 ]; then
		command nemo ./
	else
		command nemo "$@"
	fi
}

## ls function that prints hidden files when there are no regular files
## or if we are in a directory that matches the regex in LS_SHOW_ALL_DIRS
function _ls_show_hidden() {
	# Can be overwritten by settings it before calling
	local LS_SHOW_ALL_DIRS=${LS_SHOW_ALL_DIRS:-"dotfiles|\.config"}

	# if a path is given, target will contain the given directory or the directory in which the
	# given file is located
	local target
	for arg in "$@"; do
		if [ -d "$arg" ]; then
			target="$arg"
			break
		elif [ -d "${arg%/*}" ]; then
			target="${arg%/*}"
			break
		fi
	done
	if [[ -z "$(command ls "$@")" || "$( (cd "$target"; pwd) )" =~ "${LS_SHOW_ALL_DIRS:-^$}" ]]; then
		command ls -A "$@"
	else
		command ls "$@"
	fi
}
