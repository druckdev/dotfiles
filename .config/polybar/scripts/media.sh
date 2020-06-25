#!/bin/sh

command -v playerctl >/dev/null 2>&1 || { printf "playerctl not found.\n" >&2; exit 1; }

# metadata="$(playerctl metadata --format '{{status}} {{artist}} - {{title}} ({{duration(position)}}|{{duration(mpris:length)}})')"
metadata="$(playerctl metadata --format '{{status}} {{artist}}' 2>/dev/null)"
title="$(playerctl metadata --format '{{title}}' 2>/dev/null)"
duration="$(playerctl metadata --format '({{duration(position)}}|{{duration(mpris:length)}})' 2>/dev/null)"


if [ -n "$metadata" ] && [ "$metadata" != "No players found" ]; then
	# Extract status (Playing|Paused)
	status="${metadata%% *}"
	artists="${metadata#* }"

	if [ "$status" = "Playing" ]; then
		icon="" # \uf04b
	else
		icon="" # \uf04c
	fi

	if [ ${#artists} -gt 15 ]; then
		artists="$(echo "$artists" | cut -c -15)..."
	fi
	art_len=${#artists}
	if [ ${#title} -gt $((30 + 15 - art_len)) ]; then
		title="$(echo "$title" | cut -c -30)..."
	fi
	printf "$icon $artists - $title $duration"
fi

printf "\n"
