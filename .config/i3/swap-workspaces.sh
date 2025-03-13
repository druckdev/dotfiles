#!/bin/bash

workspaces="$(i3-msg -t get_workspaces | jq '.[] | select(.visible)')"

num_ws="$(<<<"$workspaces" jq '.id' | wc -l)"
if (( num_ws != 2 )); then
	echo >&2 "Unsupported amount of workspaces."
	exit 1
fi

cur="$(<<<"$workspaces" jq 'select(.focused).id')"
oth="$(<<<"$workspaces" jq 'select(.focused | not).id')"

# i3-msg "[con_id=$cur] swap container with con_id $oth"

tmp="$cur"
exists="$(<<<"$workspaces" jq "select(.name == \"$tmp\")")"
while [[ $exists ]]; do
	tmp="${tmp}0"
	exists="$(<<<"$workspaces" jq "select(.name == \"$tmp\")")"
done

i3-msg "[con_id=$cur] move workspace $tmp"
