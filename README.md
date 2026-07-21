# Fedora Silverblue - Intel Core Ultra Engine

[![bluebuild build badge](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml/badge.svg)](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml)

This repository hosts a custom, hardware-optimized system image of **Fedora Silverblue** built with [BlueBuild](https://blue-build.org/). It targets modern Intel architectures — specifically **Intel Core Ultra (Meteor Lake, Arrow Lake, and Lunar Lake)** platforms — delivering minimal power draw, reduced CPU interrupts, and smooth graphic performance.

> **Note:** This image uses the **i915** GPU driver (the Intel-supported driver for Meteor Lake and Arrow Lake). Lunar Lake uses the **xe** driver by default. No driver blacklisting or force-probing is applied — the kernel auto-selects the correct driver per platform.

---

## Architectural Enhancements

### 1. Hardware Acceleration
* **VA-API / QuickSync:** `intel-media-driver` (iHD) + `libva-intel-driver` (i965 fallback) for full H.264, HEVC, VP9, and AV1 hardware decode/encode via GStreamer and FFmpeg.
* **GPU Compute:** `intel-opencl` and `intel-level-zero-gpu` for OpenCL and oneAPI/SYCL workloads.
* **Intel NPU:** `intel-npu-driver` with custom udev rules (`/dev/accel*`) for hardware-accelerated AI/ML inference.
* **GPU Scheduling:** `i915.enable_guc=2` offloads GPU workload scheduling to the Graphics Microcontroller, reducing CPU overhead.
* **Flatpak GPU Access:** Global override exposes `dri`, `shm`, and `all` devices plus PipeWire socket to sandboxed applications.

### 2. Battery & Thermal Tuning
* **tuned-ppd:** Uses Fedora's native power profile daemon (default since Fedora 41) for dynamic CPU governor and EPP management.
* **intel-lpmd:** Enabled natively by `fedora-release-silverblue` for E-core task distribution.
* **Deepest CPU Sleep States:** `intel_idle.max_cstate=10` enables Package C10 during idle.
* **Display Power States:** `i915.enable_dc=2` enables DC5/DC6 for 0.5–1.5W idle GPU power reduction.
* **Frame Buffer Compression:** `i915.enable_fbc=1` reduces memory bandwidth during static display.
* **Panel Self Refresh:** `i915.enable_psr=1` allows the display panel to refresh itself while the GPU idles.
  > If you experience screen flickering, disable with: `rpm-ostree kargs --append=i915.enable_psr=0`
* **Thermal Control:** `thermald` with native hardware feedback profiles.

### 3. Memory & Disk Optimization
* **ZRAM with zstd:1:** Declarative `zram-generator.conf` with level-1 zstd compression (>500 MB/s per core).
* **Swappiness 100:** Kernel proactively compresses idle pages into ZRAM, freeing RAM for file cache.
* **BBR + fq:** TCP congestion control with Fair Queueing for optimal network throughput.

### 4. Audio
* **WirePlumber:** Suspends inactive sound devices after 5 seconds of silence.
* **snd_sof DSP power save:** Enabled for Intel's Sound Open Firmware driver.

### 5. Security
* **Full IOMMU:** `intel_iommu=on` without passthrough for DMA protection.
* **Kernel Lockdown:** `lockdown=integrity` prevents runtime kernel modification.
* **Memory Initialization:** `init_on_alloc=1` and `init_on_free=1` prevent information leaks.
* **Sigstore Cosign:** Image signed with key-based signing.

---

## Installation

### Step 1: Rebase to the Unverified Image

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest
```

### Step 2: Reboot

```bash
systemctl reboot
```

### Step 3: Rebase to the Signed Image

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest
```

### Step 4: Reboot

```bash
systemctl reboot
```

---

## Post-Install: Firefox Hardware Acceleration

Open Firefox Flatpak, navigate to `about:config`, and set:

```
media.ffmpeg.vaapi.enabled = true
media.hardware-video-decoding.force-enabled = true
gfx.webrender.all = true
```

Verify at `about:support`:
- **Compositing:** WebRender
- **HW_COMPOSITING:** available
- **VIDEO_DECODE:** available

---

## Verification

### Image Signature

```bash
cosign verify --key cosign.pub ghcr.io/godwin-binoy/fedora-silverblue-bluebuild@sha256:<DIGEST>
```

> Always verify by **digest**, not by tag.

### Hardware Acceleration

```bash
# VA-API (video decode/encode)
vainfo

# Vulkan (GPU compute, compositing)
vulkaninfo --summary

# OpenGL (compositing)
glxinfo | grep "OpenGL renderer"

# NPU (AI/ML)
ls /dev/accel/

# GPU driver
lspci -k | grep -A3 "VGA"

# Crypto acceleration
grep -i aes /proc/crypto | head -5

# ZRAM
zramctl

# GStreamer VA-API pipeline
gst-launch-1.0 filesrc location=test.mp4 ! decodebin ! vaapisink
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Screen flickering | `rpm-ostree kargs --append=i915.enable_psr=0` |
| No GPU acceleration | Verify `vainfo` shows iHD driver; check `LIBVA_DRIVER_NAME=iHD` |
| Audio pops/clicks | Increase `session.suspend-timeout-seconds` in WirePlumber config |
| Build fails | Check GitHub Actions logs; ensure `blue-build/github-action@v1.11.1` is pinned |
