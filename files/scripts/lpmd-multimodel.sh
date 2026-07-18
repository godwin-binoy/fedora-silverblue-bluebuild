#!/usr/bin/env bash
set -eou pipefail

# Clone custom LPMD parameters to all known Core Ultra / Meteor Lake platform configurations
TARGET_DIR="/etc/intel_lpmd"
SOURCE_CONF="${TARGET_DIR}/intel_lpmd_config.xml"

if [ -f "$SOURCE_CONF" ]; then
    echo "Duplicating LPMD optimizations to model-specific hardware configs..."
    # Copy configuration to the default Meteor Lake and Arrow/Lunar Lake config filenames
    cp "$SOURCE_CONF" "${TARGET_DIR}/intel_lpmd_config_F6_M170.xml"
    cp "$SOURCE_CONF" "${TARGET_DIR}/intel_lpmd_config_F6_M194.xml"
fi