#!/bin/sh

basedir="$(cd "$(dirname "$0")" && pwd -P)"
compositor="$(basename "$basedir")"

if [ "$1" = "-k" ];  then
	killall -q "$compositor"
elif ! pgrep -ax "$compositor" >/dev/null 2>&1; then
	"$compositor" --config "$basedir/$compositor".conf -b
fi
