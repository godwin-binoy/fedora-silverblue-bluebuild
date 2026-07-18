#!/bin/bash
set -oue pipefail

# Regenerate kernel module dependencies for CachyOS kernel
# This ensures dracut can properly generate initramfs during kernel post-transaction
echo "Regenerating kernel module dependencies..."

# Find the installed CachyOS kernel version
KERNEL_VERSION=$(ls -t /lib/modules/ | grep cachyos | head -n1)

if [ -n "$KERNEL_VERSION" ]; then
    echo "Running depmod for kernel version: $KERNEL_VERSION"
    /usr/sbin/depmod -a "$KERNEL_VERSION"
    echo "depmod completed successfully"
else
    echo "Warning: Could not find CachyOS kernel version"
fi
