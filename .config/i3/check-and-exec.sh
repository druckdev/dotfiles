#!/bin/sh

[ $# -gt 0 ] || exit 1

if ! command -v "$1" >/dev/null 2>&1; then
	i3-nagbar -m "$1: command not found"
else
	"$@"
fi
