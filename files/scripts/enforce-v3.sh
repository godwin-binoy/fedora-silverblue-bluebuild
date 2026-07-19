#!/usr/bin/env bash
set -euo pipefail

echo "Configuring build container to enforce x86_64_v3 microarchitecture..."

# Create platform override for RPM
mkdir -p /etc/rpm
echo "x86_64_v3-redhat-linux" > /etc/rpm/platform

# Create architecture override for DNF4
mkdir -p /etc/dnf
cat << 'EOF_INNER' > /etc/dnf/dnf.conf
[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
arch=x86_64_v3
EOF_INNER

# Copy overrides to DNF5 config directory if present
if [ -d "/etc/dnf5" ] || [ -d "/usr/share/dnf5" ]; then
    mkdir -p /etc/dnf5
    cp /etc/dnf/dnf.conf /etc/dnf5/dnf.conf || true
fi

echo "Architecture overrides successfully written. Executing distro-sync to replace legacy binaries..."
if command -v dnf5 &> /dev/null; then
    dnf5 distro-sync -y --allowerasing || true
elif command -v dnf &> /dev/null; then
    dnf distro-sync -y --allowerasing || true
else
    echo "Warning: No standard dnf/dnf5 executable detected in the build environment context."
fi
