#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Print the current working directory of the focused kitty window. Returns 4 if
# none exist or is focused.

socket_path="${TMPDIR:-/tmp}/kitty.$USER/kitty.sock"

# NOTE: the backticks are used for hacky line-continuation, taken from
#       https://stackoverflow.com/a/7729087/2092762c9
kitten @ --to unix:"$socket_path" ls \
	| jq -er ".[]`
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
