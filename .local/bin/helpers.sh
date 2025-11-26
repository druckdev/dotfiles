#!/bin/sh
#
# A collection of useful shell functions. This file should be sourced, rather
# than executed.
#
# All functions should be compatible with POSIX shells (dash), bash and zsh.


# Print error message, prepended by the programs name, and then exit
#
# Usage: die [<MESSAGE>] [<EXIT_CODE>]
die() {
	[ -z "$1" ] || >&2 printf "%s: %s\n" "$0" "$1"
	exit "${2:-1}"
}
