#!/bin/sh

killall waybar 2>/dev/null

sh -c 'waybar' >/dev/null 2>&1 &
disown
