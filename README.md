# Fedora Silverblue - Intel Core Ultra Engine

[![bluebuild build badge](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml/badge.svg)](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml)

Custom hardware-optimized **Fedora Silverblue** image built with [BlueBuild](https://blue-build.org/) for **Intel Core Ultra** (Meteor Lake, Arrow Lake, Lunar Lake) platforms.

> Uses the kernel's native driver selection — **i915** for Meteor Lake/Arrow Lake, **xe** for Lunar Lake. No driver blacklisting or force-probing.

---

## Hardware Acceleration Stack

| Layer | Package | Purpose |
|---|---|---|
| VA-API (primary) | `intel-media-driver` | H.264/HEVC/VP9/AV1 decode+encode via iHD |
| VA-API (fallback) | `libva-intel-driver` | Legacy i965 driver for older apps |
| GStreamer | `gstreamer1-vaapi` | Hardware-accelerated media pipeline |
| FFmpeg | `ffmpeg` (RPMFusion) | Full codec support with VA-API |
| OpenCL | `intel-opencl` | GPU compute workloads |
| Level Zero | `intel-level-zero` | oneAPI / SYCL GPU compute |
| NPU | `intel-npu-driver` | AI/ML inference on Intel NPU |
| Flatpak GPU | Global override | `devices=all` + PipeWire for sandboxed apps |

### GPU Kernel Parameters (i915)

| Parameter | Effect |
|---|---|
| `i915.enable_guc=2` | Offloads GPU scheduling to GuC microcontroller |
| `i915.enable_dc=2` | DC5/DC6 display power states (−0.5–1.5W idle) |
| `i915.enable_fbc=1` | Frame Buffer Compression (reduces memory bandwidth) |
| `i915.enable_psr=1` | Panel Self Refresh (GPU idles on static content) |

> If you experience screen flickering: `rpm-ostree kargs --append=i915.enable_psr=0`

---

## Power & Thermal

- **tuned-ppd** — Fedora's native power profile daemon (default since F41)
- **intel-lpmd** — Enabled natively by `fedora-release-silverblue`
- **thermald** — Hardware thermal feedback profiles
- **intel_idle.max_cstate=10** — Deepest CPU sleep states
- **ZRAM zstd:1** — Compressed swap at >500 MB/s per core
- **vm.swappiness=100** — Proactive ZRAM usage

## Security

- `intel_iommu=on` — Full DMA protection (no passthrough)
- `lockdown=integrity` — Kernel runtime modification blocked
- `init_on_alloc=1` / `init_on_free=1` — Memory zeroing
- AES-NI / SHA-NI hardware crypto acceleration
- Sigstore Cosign image signing

---

## Installation

```bash
# Step 1: Rebase to unverified image
rpm-ostree rebase ostree-unverified-registry:ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest

# Step 2: Reboot
systemctl reboot

# Step 3: Rebase to signed image
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest

# Step 4: Reboot
systemctl reboot
```

## Post-Install: Firefox Hardware Acceleration

Open Firefox Flatpak → `about:config`:

```
media.ffmpeg.vaapi.enabled = true
media.hardware-video-decoding.force-enabled = true
gfx.webrender.all = true
```

Verify at `about:support`: **Compositing: WebRender**, **HW_COMPOSITING: available**

---

## Verification

```bash
cosign verify --key cosign.pub ghcr.io/godwin-binoy/fedora-silverblue-bluebuild@sha256:<DIGEST>
```

```bash
vainfo                          # VA-API profiles
vulkaninfo --summary            # Vulkan GPU
glxinfo | grep "OpenGL renderer" # OpenGL
ls /dev/accel/                  # NPU
lspci -k | grep -A3 "VGA"      # GPU driver
grep -i aes /proc/crypto        # AES-NI
zramctl                         # ZRAM status
ffmpeg -hwaccels                # FFmpeg HW accel
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| Screen flickering | `rpm-ostree kargs --append=i915.enable_psr=0` |
| No VA-API in Firefox | Check `about:config` settings above |
| Audio pops/clicks | Increase `session.suspend-timeout-seconds` in WirePlumber |
| Build fails | Check Actions logs; verify `@v1.11.1` pin |
