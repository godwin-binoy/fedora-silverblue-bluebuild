#!/usr/bin/env bash
set -euo pipefail

CPU_MODEL=$(awk -F': ' '/model\s*:/ {print $2; exit}' /proc/cpuinfo | tr -d ' ')
TOTAL_RAM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
TOTAL_THREADS=$(nproc)

HAS_LPE=0
# Supports Meteor Lake (170/171), Lunar Lake (189), and Arrow Lake (198/199/200)
if [[ "$CPU_MODEL" =~ ^(170|171|189|198|199|200)$ ]]; then
    HAS_LPE=1
fi

if [ "$HAS_LPE" -eq 1 ]; then
    systemctl enable --now intel_lpmd.service || true
    if [ "$TOTAL_THREADS" -le 14 ]; then
        sed -i 's/<util_entry_threshold>[0-9]*<\/util_entry_threshold>/<util_entry_threshold>10<\/util_entry_threshold>/g' /etc/intel_lpmd/intel_lpmd_config.xml 2>/dev/null || true
        sed -i 's/<util_exit_threshold>[0-9]*<\/util_exit_threshold>/<util_exit_threshold>35<\/util_exit_threshold>/g' /etc/intel_lpmd/intel_lpmd_config.xml 2>/dev/null || true
    fi
else
    systemctl disable --now intel_lpmd.service || true
fi

ZRAM_TARGET_SIZE="ram"
VM_SWAPPINESS_TARGET=130
if [ "$TOTAL_RAM_KB" -ge 31457280 ]; then
    ZRAM_TARGET_SIZE="16384"
    VM_SWAPPINESS_TARGET=60
fi

CURRENT_ZRAM_SIZE=$(grep -oP "(?<=zram-size = ).*" /etc/systemd/zram-generator.conf 2>/dev/null || echo "")

if [ "$CURRENT_ZRAM_SIZE" != "$ZRAM_TARGET_SIZE" ]; then
    cat <<EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ${ZRAM_TARGET_SIZE}
compression-algorithm = zstd
swap-priority = 100
