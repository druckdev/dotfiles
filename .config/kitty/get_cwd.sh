#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Usage: kitty-cwd [GROUP_NAME]
#
# Print the current working directory of the focused kitty window. Returns 4 if
# none exist or is focused.

if [ -n "$KITTY_LISTEN_ON" ]; then
	socket_path="${KITTY_LISTEN_ON#unix:}"
else
	socket_path="${TMPDIR:-/tmp}/kitty.$USER/kitty${1:+-$1}.sock"
fi
[ -e "$socket_path" ] || exit 1

# NOTE: Unfortunately kitten-@-ls(1) is slow, so communicate with the socket
#       directly.
printf '\eP@kitty-cmd{%s,%s,%s}\e\\' \
	'"cmd":"ls"' \
	'"version":[0,26,0]' \
	'"payload":{"match":"state:focused"}' \
| nc -U -q0 "$socket_path" \
| awk '{ print substr($0, 13, length($0) - 14) }' \
| jq -er ".data | fromjson | .[].tabs.[].windows.[].cwd"
