#!/usr/bin/env bash
set -euo pipefail

FEDORA_VERSION="$(rpm -E %fedora)"
FREE_RPM="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"
NONFREE_RPM="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"

# Skip if already installed (idempotency)
if rpm -q rpmfusion-free-release rpmfusion-nonfree-release &>/dev/null; then
    echo "RPMFusion repositories already installed. Skipping."
    exit 0
fi

echo "Installing RPMFusion repositories for Fedora ${FEDORA_VERSION}..."

MAX_RETRIES=3
RETRY_DELAY=10

for attempt in $(seq 1 $MAX_RETRIES); do
    if dnf install -y "$FREE_RPM" "$NONFREE_RPM"; then
        echo "RPMFusion repositories installed successfully."
        exit 0
    fi
    echo "Attempt ${attempt}/${MAX_RETRIES} failed. Retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
done

echo "ERROR: Failed to install RPMFusion after ${MAX_RETRIES} attempts." >&2
exit 1
