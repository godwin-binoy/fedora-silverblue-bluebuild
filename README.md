# Fedora Silverblue - BlueBuild for intel Meteor Lake, Arrow Lake, and Lunar Lake cpu architectures

[![bluebuild build badge](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml/badge.svg)](https://github.com/godwin-binoy/fedora-silverblue-bluebuild/actions/workflows/build.yml)

This is a custom, hardware-optimized image of **Fedora Silverblue** built using [BlueBuild](https://blue-build.org/). It is tailored specifically for modern Intel architectures—with a focus on **Intel Core Ultra (Meteor Lake, Arrow Lake, and Lunar Lake)** platforms—to deliver balanced battery savings, lower latency, and smoother performance.

---

## Why Choose This Image?

Standard Fedora is designed to run on almost any computer, which means it uses conservative default configurations. This image pre-configures deep system-level optimizations that typically require hours of manual tuning. 

### Key Features & Optimizations

#### 1. Intel Hardware Tailoring
* **Intel Low Power Mode Daemon (LPMD):** Pre-configured and optimized to distribute light background tasks to Intel's low-power E-cores, helping extend battery life.
* **Thermal Management:** `thermald` is enabled by default to prevent thermal throttling and manage laptop surface temperatures.
* **Intel Media Driver & VA-API:** Full hardware-accelerated video playback is built-in (`intel-media-driver` and `gstreamer1-vaapi`), reducing CPU usage during video streaming.

#### 2. Advanced Power Savings
* **USB & PCIe Wakeup Suppression:** Automatically blocks unnecessary USB/PCIe devices from waking your laptop up in your bag.
* **Aggressive Audio Powersaving:** Configures sound card sleep states to reduce idle power draw.
* **Kernel Sleep State Tuning:** PCIe Active State Power Management (`pcie_aspm=auto`) and modern P-State active rules are pre-configured in the boot arguments.

#### 3. Memory & Responsiveness (Kernel Tuning)
* **Modern Memory Allocation:** Enabled multi-size Transparent Huge Pages (mTHP) specifically bounded for Intel’s modern hybrid core layouts to reduce overhead during heavy workloads.
* **ZRAM Memory Compression:** Uses a 1:1 memory-to-ZRAM ratio compressed with the fast `zstd` algorithm and configured with aggressive memory swapping (`swappiness=180`) to keep the system responsive even under heavy memory load.
* **BBR Congestion Control:** Lowers network latency and improves throughput under packet loss by utilizing Google's BBR TCP congestion control scheme.

#### 4. Audio & Desktop Enhancements
* **PipeWire Tuning:** High-priority real-time audio parameters are applied to eliminate audio crackling or popping.
* **Bluetooth Audio Boost:** High-quality Bluetooth audio codecs (SBC-XQ and mSBC) are enabled by default for cleaner wireless sound.
* **Flatpak-First Software Strategy:** Replaces resource-heavy system-level RPM packages (like Firefox and Help documentation) with sandboxed Flatpaks. These Flatpaks are configured with system-level hardware acceleration permissions out of the box.

---

## Installation

> [!WARNING]  
> This image utilizes native container delivery mechanisms which are highly reliable but still considered experimental by the broader Fedora project. Please use at your own discretion.

You can easily transition an existing Fedora Silverblue installation over to this image without losing your personal data. 

### Step 1: Rebase to the Unverified Image
First, point your system to the unverified container registry to download the image, signing keys, and security policies:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest
```

### Step 2: Reboot
Reboot your computer to apply the initial changes:

```bash
systemctl reboot
```

### Step 3: Rebase to the Signed Image
Once rebooted, lock your system to the securely signed version of the image to ensure you only receive authentic updates:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/godwin-binoy/fedora-silverblue-bluebuild:latest
```

### Step 4: Final Reboot
Reboot one last time to complete your installation:

```bash
systemctl reboot
```

---

## Verification

This image is digitally signed using [Sigstore Cosign](https://github.com/sigstore/cosign). You can verify the integrity of your downloaded image at any time.

1. Download the public key `cosign.pub` from this repository.
2. Run the following command:

```bash
cosign verify --key cosign.pub ghcr.io/godwin-binoy/fedora-silverblue-bluebuild
```

---

## Automation & Maintenance

* **Updates:** The image is automatically rebuilt every day via GitHub Actions to pull in the latest Fedora security patches and package updates.
* **Flatpak Upgrades:** A quiet systemd timer automatically checks for and updates your Flatpaks once a day, avoiding updates if you are on a metered network connection.

---

*Customized and maintained by [@godwin-binoy](https://github.com/godwin-binoy) with help from project contributors.*
