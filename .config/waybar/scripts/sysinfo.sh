#!/bin/sh
# Collapsed cpu/memory/disk module: shows CPU% in the bar, full breakdown in the tooltip.

read -r _ u1 n1 s1 i1 w1 irq1 sirq1 _ < /proc/stat
sleep 0.2
read -r _ u2 n2 s2 i2 w2 irq2 sirq2 _ < /proc/stat

prev_idle=$((i1 + w1))
idle=$((i2 + w2))
prev_total=$((u1 + n1 + s1 + i1 + w1 + irq1 + sirq1))
total=$((u2 + n2 + s2 + i2 + w2 + irq2 + sirq2))
diff_total=$((total - prev_total))
diff_idle=$((idle - prev_idle))
cpu=$(( diff_total > 0 ? (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 : 0 ))

mem_line=$(free -h | awk '/Mem:/ {printf "%s used / %s total", $3, $2}')
mem_pct=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

disk_line=$(df -h / | awk 'NR==2 {printf "%s used / %s total (%s)", $3, $2, $5}')

jq -nc --arg text " ${cpu}%" \
       --arg tooltip "CPU: ${cpu}%
Memory: ${mem_pct}% (${mem_line})
Disk (/): ${disk_line}" \
       '{text: $text, tooltip: $tooltip}'
