#!/usr/bin/env bash
set -euo pipefail

CPU_MODEL=$(cat /sys/devices/system/cpu/devices/system/cpu0/topology/model_id 2>/dev/null || awk '/model\s+:/ {print $3; exit}' /proc/cpuinfo)
TOTAL_RAM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
TOTAL_THREADS=$(nproc)

HAS_LPE=0
if [[ "$CPU_MODEL" =~ ^(170|171)$ ]]; then
    HAS_LPE=1
fi

if [ "$HAS_LPE" -eq 1 ]; then
    systemctl enable --now intel_lpmd.service
    if [ "$TOTAL_THREADS" -le 14 ]; then
        sed -i 's/<util_entry_threshold>[0-9]*<\/util_entry_threshold>/<util_entry_threshold>10<\/util_entry_threshold>/g' /etc/intel_lpmd/intel_lpmd_config.xml
        sed -i 's/<util_exit_threshold>[0-9]*<\/util_exit_threshold>/<util_exit_threshold>35<\/util_exit_threshold>/g' /etc/intel_lpmd/intel_lpmd_config.xml
    fi
else
    systemctl disable --now intel_lpmd.service || true
fi

if [ "$TOTAL_RAM_KB" -lt 31457280 ]; then
    echo -e "[zram0]\nzram-size = ram\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf
    sysctl vm.swappiness=130
else
    echo -e "[zram0]\nzram-size = 16384\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf
    sysctl vm.swappiness=60
fi

systemctl daemon-reload
systemctl restart systemd-zram-setup@zram0.service || true
