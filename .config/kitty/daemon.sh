#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
#
# Usage: kitty-daemon [GROUP_NAME]
#
# Daemonize kitty by launching one hidden instance that new invocations can use
# to create new OS windows. This makes kitty startup a lot faster since all
# windows can now share a single CPU process and GPU sprite cache. Additionally
# allow remote_control over a socket, so that kitty-cwd works.
#
# To launch new invocations using the daemon created by this script use:
#
#     kitty --single-instance
#
# You can pass an optional instance-group as first parameter. In that case use:
#
#     kitty --single-instance --instance-group <NAME>
#
# NOTE: `--start-as hidden` needs kitty 0.42.0 or later.

TMP_DIR="${TMPDIR:-/tmp}/kitty.$USER"
mkdir -p "$TMP_DIR"

name="kitty${1:+-$1}"

kitty \
	--single-instance \
	${1:+--instance-group "$1"} \
	--start-as hidden \
	--detach \
	--detached-log "$(mktemp -p "$TMP_DIR" "$name.XXXXXX.log")" \
	-o allow_remote_control=socket-only \
	--listen-on unix:"$TMP_DIR/$name.sock"
