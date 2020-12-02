#!/bin/bash
# script set in background
setsid /init.sh &

# run systemd
exec /usr/sbin/init
