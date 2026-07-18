#!/usr/bin/env bash
set -euo pipefail

# Read AC power status online state
ONLINE=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -n 1 || echo 1)

if [ "$ONLINE" -eq 1 ]; then
    # System is connected to wall power; deploy low-latency user-space scheduler
    if systemctl is-enabled scx_loader.service >/dev/null 2>&1; then
        echo "AC Connected: Enabling high-performance sched-ext loop."
        systemctl start scx_loader.service || true
    fi
else
    # System is running on battery; yield scheduler loops back to default kernel EEVDF
    echo "Battery Detected: Pausing sched-ext to utilize low-power native EEVDF."
    systemctl stop scx_loader.service || true
fi