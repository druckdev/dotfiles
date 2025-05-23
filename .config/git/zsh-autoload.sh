#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Meant to be used in git aliases to launch an autoloadable zsh function in the
# correct directory.

if [ $# -eq 0 ]; then
	printf >&2 "Usage: $(basename "$0") <function>\n"
	exit 1
fi

BASE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/autoload/git"

# In git aliases, shell commands are executed from the top-level directory of
# the repo. GIT_PREFIX contains the original directory relative to the
# top-level.
[ -z "$GIT_PREFIX" ] || cd "$GIT_PREFIX"

# no need for error handling, the message from sh is descriptive enough
if [ "${1#git-}" != "$1" ] || [ -e "$BASE/$1" ]; then
	exec "$BASE/$@"
else
	exec "$BASE/git-$@"
fi
