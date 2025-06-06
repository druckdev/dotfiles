#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Script to simulate output-independent workspaces. Can be used to switch and/or
# move a container to the workspace.

set -eu

switch=
move=

usage() {
	printf >&2 "Usage: %s [-s] [-m] <index>\n" "$0"
	exit "${1:-0}"
}

while getopts "sm" flag; do
	case $flag in
		s) switch=1;;
		m) move=1;;
		*) usage 1;;
	esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || usage

outputs="$(i3-msg -t get_outputs | jq -r '.[] | select(.active).name')"
num_outs="$(printf "%s\n" "$outputs" | wc -l)"

if [ "$num_outs" -lt 2 ]; then
	# only one monitor
	workspace="$1"
else
	name="$(i3-msg -t get_tree \
		| jq -r '.. | objects | select(.focused).output')"
	num="$(printf "%s\n" "$outputs" \
		| grep -Fxn "$name" \
		| cut -d: -f1)"
	num="$((num - 1))"

	# Omit the number on the first monitor
	[ "$num" -gt 0 ] || num=

	workspace="$num$1"
fi

if [ -z "$switch" ] && [ -z "$move" ]; then
	printf "%s\n" "$workspace"
	exit 0
fi

cmd=
[ -z "$move" ] || cmd="move container to workspace $workspace"
[ -z "$switch" ] || cmd="$cmd${cmd:+; }workspace $workspace"
i3-msg "$cmd"
