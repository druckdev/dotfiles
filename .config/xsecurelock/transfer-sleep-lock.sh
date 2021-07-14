#!/usr/bin/env bash
# !Modified! /usr/share/doc/xss-lock/transfer-sleep-lock-generic-delay.sh

# Example locker script -- demonstrates how to use the --transfer-sleep-lock
# option with a fixed delay to give simple lockers a little bit of time to lock
# the screen before the system goes the sleep.

## CONFIGURATION ##############################################################

# Source configuration
source "$(dirname "$0")/config"

# Command to start the locker (should not fork)
locker=xsecurelock

# Delay in seconds. Note that by default systemd-logind allows a maximum sleep
# delay of 5 seconds.
sleep_delay=1

# Run before starting the locker
pre_lock() {
    playerctl pause
    "${XDG_CONFIG_HOME:-$HOME/.config}/compositor/launch.sh" -k
    amixer -q -D pulse sset Master mute
    return
}

# Run after the locker exits
post_lock() {
    "${XDG_CONFIG_HOME:-$HOME/.config}/compositor/launch.sh"
    return
}

###############################################################################

pre_lock

# kill locker if we get killed
trap 'kill %%' TERM INT

if [[ -e /dev/fd/${XSS_SLEEP_LOCK_FD:--1} ]]; then
    # lock fd is open, make sure the locker does not inherit a copy
    $locker {XSS_SLEEP_LOCK_FD}<&- &

    sleep $sleep_delay

    # now close our fd (only remaining copy) to indicate we're ready to sleep
    exec {XSS_SLEEP_LOCK_FD}<&-
else
    $locker &
fi

wait # for locker to exit

post_lock
