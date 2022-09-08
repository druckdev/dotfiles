#!/bin/sh
#
# Create a key-table which self-inserts all keys that are bound in the root key
# table. (C-h for example is sometimes needed as backspace sequence)

tmux list-keys -T root | awk '{print $4}' | while read key; do
	tmux bind -r -T selfinsert "$key" send
done
