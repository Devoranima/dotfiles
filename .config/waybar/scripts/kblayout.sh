#!/bin/bash

hyprctl devices -j | jq -r '.keyboards[]|select(.main == true) | if .capsLock then .active_keymap[0:2] | ascii_upcase else .active_keymap[0:2] | ascii_downcase end'
