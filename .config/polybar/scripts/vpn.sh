#!/bin/sh

connection="$(nmcli con show --active | awk '$3 ~ /^(vpn|tun|wireguard)$/ { print $1 }')"
if [ -n "$connection" ]; then
	if [ "$connection" = "wg-mullvad" ]; then
		connection="$(mullvad status | awk '{ print $3}')"
	fi
	echo "VPN: $connection"
	exit 0
fi

# [o] is a hack to not grep the grep-command. See:
# https://stackoverflow.com/questions/9375711/more-elegant-ps-aux-grep-v-grep
if ps ax | grep -q "[o]penvpn"; then
	echo "VPN"
	exit 0
fi

echo
exit 1
