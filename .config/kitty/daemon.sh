#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Julian Prein
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
# NOTE: `--start-as hidden` needs kitty 0.42.0 or later.

kitty \
	--single-instance \
	--start-as hidden \
	--detach \
	-o allow_remote_control=socket-only \
	--listen-on unix:/tmp/mykitty
