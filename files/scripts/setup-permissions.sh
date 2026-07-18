#!/usr/bin/env bash
set -eou pipefail

# Ensure custom local binary scripts carry valid execution flags
if [ -f "/usr/local/bin/scx-power-switch.sh" ]; then
    chmod +x /usr/local/bin/scx-power-switch.sh
fi