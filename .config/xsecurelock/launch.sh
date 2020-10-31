#!/bin/sh

xss-lock -l "$(cd "$(dirname "$0")" && pwd -P)"/transfer-sleep-lock.sh &
