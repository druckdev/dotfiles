#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Usage: kitty-cwd [GROUP_NAME]
#
# Print the current working directory of the focused kitty window. Returns 4 if
# none exist or is focused.

socket_path="${TMPDIR:-/tmp}/kitty.$USER/kitty${1:+-$1}.sock"

# NOTE: Unfortunately kitten-@-ls(1) is slow, so communicate with the socket
#       directly.
# NOTE: the backticks are used for hacky line-continuation, taken from
#       https://stackoverflow.com/a/7729087/2092762c9
printf '\eP@kitty-cmd{"cmd":"ls","version":[0,26,0]}\e\\' \
| nc -U -q0 "$socket_path" \
| awk '{ print substr($0, 13, length($0) - 14) }' \
| jq -er ".data`
	` | fromjson`
	` | .[]`
	` | select(.is_focused).tabs.[]`
	` | select(.is_focused).windows.[]`
	` | select(.is_focused).cwd"

# An alternative version that uses recursive descent to find focused objects
# that also have a `.cwd` key:
#
#	| jq -er "..`
#		` | objects`
#		` | select(.is_focused)`
#		` | to_entries.[]`
#		` | select(.key == \"cwd\").value"
