#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Meant to be used by git aliases to easily launch an external script from the
# ./scripts/ collection through its basename and in the correct directory (i.e.
# GIT_PREFIX).

if [ $# -eq 0 ]; then
	printf >&2 "Usage: %s <function>\n" "$(basename "$0")"
	exit 1
fi
name="$1"
shift

BASE="$(dirname "$(realpath "$0")")/scripts"

# In git aliases, shell commands are executed from the top-level directory of
# the repo. GIT_PREFIX contains the original directory relative to the
# top-level.
[ -z "$GIT_PREFIX" ] || cd "$GIT_PREFIX" || exit

# no need for error handling, the message from sh is descriptive enough
if [ "${name#git-}" != "$name" ] || [ -e "$BASE/$name" ]; then
	exec "$BASE/$name" "$@"
else
	exec "$BASE/git-$name" "$@"
fi
