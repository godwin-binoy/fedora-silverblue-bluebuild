# Fedora Silverblue — Intel Core Ultra Engine

[![bluebuild build badge](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml/badge.svg)](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml)

Custom hardware-optimized **Fedora Silverblue** image built with [BlueBuild](https://blue-build.org/) for **Intel Core Ultra** (Meteor Lake, Arrow Lake, Lunar Lake) platforms.

> Uses the **i915** driver — the kernel default for all current Intel Core Ultra platforms. The experimental `xe` driver can be manually enabled via `force_probe` if desired.

---

## Hardware Acceleration Stack

| Layer | Package | Purpose |
|---|---|---|
| VA-API (primary) | `libva-intel-media-driver` | H.264/HEVC/VP9/AV1 decode+encode via iHD |
| VA-API (fallback) | `libva-intel-driver` | Legacy i965 driver for older apps |
| GStreamer | `gstreamer1-vaapi` | Hardware-accelerated media pipeline |
| FFmpeg | `ffmpeg` (RPMFusion) | Full codec support with VA-API |
| OpenCL | `intel-opencl` | GPU compute workloads |
| Level Zero | `intel-level-zero` | oneAPI / SYCL GPU compute |
| NPU | `intel-npu-driver` | AI/ML inference on Intel NPU |
| Flatpak GPU | Global override | `devices=dri;shm` + PipeWire for sandboxed apps |

### GPU Defaults (i915 — Meteor Lake+)

The kernel automatically selects optimal defaults for Meteor Lake and newer:

| Parameter | Default | Effect |
|---|---|---|
| `i915.enable_guc` | `3` | GuC submission + HuC firmware (GPU scheduling offload) |
| `i915.enable_psr` | `-1` (auto) | PSR2 on supported eDP panels (GPU idles on static content) |
| `i915.enable_dc` | `-1` (auto) | Best available DC power state |
| `i915.enable_fbc` | `-1` (auto) | Frame Buffer Compression enabled |

> These defaults are **not overridden** in this image. Setting them explicitly can only downgrade or be redundant.
> If you experience screen flickering: `rpm-ostree kargs --append=i915.enable_psr=0`

---

## Power & Thermal

- **tuned-ppd** — Fedora's power profile daemon with tuned backend (default since F41)
- **intel-lpmd** — Enabled natively by `fedora-release-silverblue`
- **thermald** — Hardware thermal feedback profiles
- **intel_idle.max_cstate=10** — Deepest CPU sleep states
- **ZRAM zstd:1** — Compressed swap at >500 MB/s per core
- **vm.swappiness=80** — Proactive but balanced ZRAM usage
- **USB/PCIe wakeup disabled** — Reduces spurious wake cycles from sleep
- **Runtime PM** — Scoped to Intel PCI devices only (avoids NVMe/GPU instability)
- **NVMe power** — `default_ps_max_latency_us=5500` reduces idle power ~0.5W
- **RCU tuning** — `rcu_idle_gp_delay=1` reduces timer wakeups
- **ACPI EC** — `ec_no_wakeup=1` reduces spurious embedded controller wakeups

## Security

- `intel_iommu=on` — Full DMA protection (no passthrough)
- `init_on_alloc=1` / `init_on_free=1` — Memory zeroing
- AES-NI / SHA-NI hardware crypto acceleration
- Sigstore Cosign image signing
- Flatpak sandboxing with minimal device access (`dri;shm` only)

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
lspci -k | grep -A3 "VGA"      # GPU driver (should show i915)
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
| Build fails | Check Actions logs; verify `@v1.12.0` pin |
| RPMFusion install fails | Mirrors use Anubis bot-protection; script retries 3x automatically |

## Updates

- Base image is pinned to **Fedora 44** for reproducibility
- A monthly workflow checks for new Fedora releases and opens a PR
- `rpm-ostreed` is configured with `AutomaticUpdatePolicy=stage` — updates download in background and apply on reboot
- Flatpak updates run weekly (Saturday 10:00, with 6h random delay)
