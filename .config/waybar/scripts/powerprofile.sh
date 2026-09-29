#!/usr/bin/env bash

style="$HOME/.config/waybar/scripts/powerprofile.css"
cur=$(powerprofilesctl get 2>/dev/null)

mark() { [ "$1" = "$cur" ] && printf "  ●"; }

options="󰌪  Power Saver$(mark power-saver)
󰊚  Balanced$(mark balanced)
󰓅  Performance$(mark performance)"

chosen=$(printf '%s' "$options" | wofi --dmenu \
    --prompt "Power Profile" \
    --style "$style" \
    --width 300 --height 165 \
    --location center \
    --cache-file /dev/null)

case "$chosen" in
    *Saver*)       powerprofilesctl set power-saver ;;
    *Balanced*)    powerprofilesctl set balanced ;;
    *Performance*) powerprofilesctl set performance ;;
esac
