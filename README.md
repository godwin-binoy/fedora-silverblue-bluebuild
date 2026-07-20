# Fedora Silverblue - Intel Core Ultra Engine

[![bluebuild build badge](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml/badge.svg)](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml)

This repository hosts a custom, hardware-optimized system image of **Fedora Silverblue** built with [BlueBuild](https://blue-build.org/). It targets modern Intel architectures—specifically **Intel Core Ultra (Meteor Lake, Arrow Lake, and Lunar Lake)** platforms—delivering minimal power draw, reduced CPU interrupts, and smooth graphic performance.

---

## Direct Architectural Enhancements

### 1. Unlocked Hardware Accelerations
* **Intel VPU/NPU (Neural Processing Unit):** Integrates the `intel-npu-driver` with custom udev rules to enable local hardware-accelerated AI computations and machine learning execution for userspace frameworks.
* **Intel QuickSync & OpenCL:** Bundles `onevpl-intel-gpu` and `intel-opencl` to provide GPU-compute and hardware video encoding pipelines.
* **Global Flatpak Integrations:** Deploys master policies inside `/etc/flatpak/overrides/global` to enforce Wayland rendering, IPC shared memory (`shm`), direct GPU access (`dri`), and expose both the NPU (`/dev/accel`) and host OpenCL libraries to sandboxed applications.

### 2. Battery & Thermal Tuning
* **Native PowerTOP Service:** Enforces built-in `powertop.service` tuning to auto-align device power states during boot cycles.
* **Deepest CPU Sleep States:** Configures `intel_idle.max_cstate=10` as a kernel boot parameter, enabling your processor cores to enter their lowest power-consuming state (Package C10) during idle periods.
* **Suppression of CPU Wake Cycles:** Extends dirty memory writeback intervals and limits logging wakeups to drop system-wide idle interrupts below 50 wakeups per second.
* **Intel Low Power Mode Daemon (LPMD):** Utilizes `intel-lpmd` to distribute light background tasks to Intel's low-power E-cores dynamically.
* **Thermal Control:** Runs `thermald` with native hardware feedback profiles to manage chassis temperatures.

### 3. Declarative Memory & Disk Optimization
* **Systemd ZRAM Scaling:** Discards stateful boot-time configuration scripts. Establishes a declarative `zram-generator.conf` mapping memory to swap spaces with high-efficiency `zstd` compression.
* **Optimized I/O Scheduler:** Implements NVMe block schedulers statically to prevent storage controller thrashing and optimize execution pipelines.

### 4. Audio Pacing
* **WirePlumber SPA-JSON Tuning:** Sets optimized ALSA buffer periods to minimize CPU interrupts during audio playback and suspends inactive sound devices after 2 seconds of silence to prevent power waste.

---

## Installation

You can transition an existing Fedora Silverblue installation over to this image without losing personal data.

### Step 1: Rebase to the Unverified Image
Run this command to fetch the custom container image and align your package manager:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest
```

### Step 2: System Restart
Reboot your system to apply initial configurations:

```bash
systemctl reboot
```

### Step 3: Align to the Signed Container
Secure your system updates by locking your deployment to the verified cryptographically signed image:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest
```

### Step 4: Final Restart
Apply all updates and complete the setup:

```bash
systemctl reboot
```

---

## Verification

The system automatically signs this image with [Sigstore Cosign](https://github.com/sigstore/cosign). Validate the cryptographic signature at any point:

1. Retrieve `cosign.pub` from the root of this repository.
2. Execute:

```bash
cosign verify --key cosign.pub ghcr.io/godwin-binoy/fedora-silverblue-bluebuild
```
