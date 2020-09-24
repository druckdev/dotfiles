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
