<div align="center">

# Bazzora 🚀

**Custom, immutable, and debloated atomic operating system optimized for Full AMD Desktop Gaming.**

[🇬🇧 English](README.md) • [🇫🇷 Français](README.fr.md)

[![Français](https://img.shields.io/badge/🇫🇷_Passer_au_Français-Lire_le_README-blue?style=for-the-badge)](README.fr.md)

<br/>

[![BlueBuild Build](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml/badge.svg)](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml)
![Base Image](https://img.shields.io/badge/Base-Bazzite--GNOME-purple?logo=linux)
![Hardware Target](https://img.shields.io/badge/Target-Full%20AMD%20(CPU%20%2B%20GPU)-ed1c24?logo=amd)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Framework](https://img.shields.io/badge/Built%20with-BlueBuild-cyan)

</div>

---

**Bazzora** is an immutable, atomic OCI container operating system based on **Fedora Atomic / Bazzite-GNOME**, tailored specifically for high-performance **Full AMD** gaming desktops (AMD Ryzen CPU + AMD Radeon GPU).

It bridges the gap between the **hardcore gaming optimizations of Valve/Bazzite** (gaming kernel, Mesa ACO drivers, proton-ge, FSR 4 readiness) and the **rock-solid sobriety of vanilla Fedora Silverblue** — completely stripping away mobile console daemons, unneeded hypervisor modules, Android subsystems, and desktop bloatware.

---

## ⚖️ Why Bazzora? (Comparison)

| Feature | Vanilla Silverblue | Default Bazzite | **Bazzora** |
| :--- | :---: | :---: | :---: |
| **Gaming Kernel (`kernel-fsync` / CachyOS)** | ❌ (Stock generic) | ✅ | ✅ **Yes** |
| **Valve Mesa Drivers (RADV ACO / 32 & 64-bit)** | ❌ (Stock Fedora) | ✅ | ✅ **Yes** |
| **Mesa XXL Shader Cache (50 GB anti-stutter)** | ❌ (Default 1 GB) | ❌ (Default 1 GB) | ✅ **Yes (50 GB)** |
| **Proton Wayland & Native HDR (Mutter Direct)** | ❌ | ⚠️ (Gamescope only) | ✅ **Yes (`ujust`)** |
| **Proton NTSYNC Kernel Fastpath** | ❌ | ⚠️ (Manual) | ✅ **Enabled by default** |
| **AMD GPU Overdrive & LACT (Undervolt/Fans)** | ❌ | ⚠️ (Flatpak, manual sudo) | ✅ **Native RPM + `lactd` daemon** |
| **Disk Partitioning Suite** | ❌ (Disks only) | ❌ (Disks only) | ✅ **GParted (Native RPM)** |
| **Low-Latency Audio (PipeWire 256 quantum)** | ❌ (1024 default) | ❌ (1024 default) | ✅ **Yes (< 5.8 ms)** |
| **CachyOS / SteamOS Sysctl Tuning (ZRAM, BBR)** | ❌ | ⚠️ (Partial) | ✅ **Full Gaming Profile** |
| **Mutter Low-Latency (No timeout freeze, VRR)** | ❌ | ❌ | ✅ **Yes (`check-alive=0`)** |
| **Clean Vanilla Desktop (Zero bloatware extensions)**| ✅ | ❌ (Compiz effects / Docks) | ✅ **Pure GNOME** |
| **Default Aesthetics (Bibata Ice & Papirus-Dark)** | ❌ (Adwaita) | ❌ (Adwaita) | ✅ **Bibata Modern Ice + Papirus** |
| **Android / Waydroid Subsystem** | ❌ | ⚠️ (Bundled) | 🚫 **Completely purged** |
| **Handheld / Console Daemons (Steam Deck/Ally)** | ❌ | ⚠️ (Bundled) | 🚫 **Completely purged** |
| **Server Administration Stack (Cockpit)** | ❌ | ⚠️ (Bundled) | 🚫 **Completely purged** |

---

## ⚡ Core Features & Optimizations

### 🎮 Full AMD High-Performance Gaming Stack
* **Valve RADV Vulkan with ACO Compiler** : High-efficiency shader compilation eliminating frame dips.
* **XXL Mesa Shader Cache (50 GB)** : Preconfigured via [10-amd-gaming.conf](files/system/etc/environment.d/10-amd-gaming.conf) (`MESA_SHADER_CACHE_MAX_SIZE=50G`) to avoid in-game shader recompilation stutter.
* **Proton NTSYNC Fastpath** : `PROTON_USE_NTSYNC=1` enabled out of the box for ultra-low overhead Windows NT synchronization.
* **AMD GPU Services (AGS) & FSR 4 Ready** : `PROTON_ENABLE_AMD_AGS=1` enabled for native FidelityFX features, with instant global FSR 4 forcing via `ujust toggle-fsr4`.
* **Proton Wayland & Native HDR** : Command `ujust toggle-proton-hdr` enables native Wayland rendering and direct Mutter HDR passthrough without the compositing overhead or color banding of nested Gamescope.
* **LACT Native RPM + Auto-Started `lactd` Daemon** : AMD GPU control panel (overclocking, undervolting, custom fan curves) packaged natively via official COPR. The `lactd.service` runs as a system daemon on boot, enabling immediate hardware control without requiring root passwords.
* **One-Click AMD Overdrive** : `ujust toggle-amdgpu-overdrive` activates `amdgpu.ppfeaturemask=0xffffffff` at the kernel level.

### ⚙️ Kernel & System Tuning (CachyOS & SteamOS Standards)
* **Gaming Memory & Swappiness Profile** ([99-bazzora-gaming.conf](files/system/etc/sysctl.d/99-bazzora-gaming.conf)):
  * `vm.max_map_count = 2147483642` : Prevents memory crashes in modern heavy games (Star Citizen, Hogwarts Legacy, DayZ, modded Skyrim).
  * `vm.swappiness = 180` with ZRAM zstd compression for responsive memory reclamation under extreme load.
  * `dirty_bytes` limits (256 MB dirty / 128 MB background) preventing bursty write stalls during high I/O spikes.
  * `bbr` + `fq` network pacing for lower jitter and ping stability in multiplayer games.
* **Transparent Hugepages (THP) Deferral** ([bazzora-thp.conf](files/system/etc/tmpfiles.d/bazzora-thp.conf)):
  * Set to `defer+madvise` to prevent memory allocation latency spikes and micro-freezes.
* **Ultra-Low Latency Audio** ([10-bazzora-gaming.conf](files/system/etc/pipewire/pipewire.conf.d/10-bazzora-gaming.conf)):
  * PipeWire forced to `min-quantum = 256` for deterministic < 5.8 ms audio latency with zero crackling or dropouts.
* **Hardware Watchdog Blacklist** ([bazzora-blacklist.conf](files/system/etc/modprobe.d/bazzora-blacklist.conf)):
  * Blacklists `sp5100_tco` on Ryzen desktop motherboards to avoid spurious hardware timeouts and random lockups.

### 🖥️ Clean GNOME Environment & Modern Styling
* **Mutter Gaming Tweaks**:
  * `check-alive-timeout = 0` : Completely disables the intrusive *"Application is not responding"* modal during long game loading screens.
  * Native Variable Refresh Rate (VRR / FreeSync) and `xwayland-native-scaling` enabled by default.
  * Flat mouse acceleration curve (`accel-profile='flat'`) for raw 1:1 precision competitive aim.
* **Default Aesthetics**:
  * **Cursor Theme** : **Bibata Modern Ice** installed system-wide (`/usr/share/icons/default/index.theme`, GNOME, GTK 3 & GTK 4, Flatpaks, XWayland).
  * **Icon Theme** : **Papirus-Dark** providing clean, high-contrast monochrome system panel icons alongside colorful app icons.
  * **GTK Theme** : Dark mode by default (`adw-gtk3-dark` + `color-scheme='prefer-dark'`).
* **Clean Productivity**:
  * Pre-packaged **GParted** for advanced drive management.
  * **ExtensionManager** installed in Flatpak to manage user extensions safely.
  * Useful shortcuts: `Ctrl+Alt+T` (Ptyxis terminal) and `Ctrl+Shift+Esc` (Mission Center).
  * Purged KDE-based updater in favor of the lightweight, yellow-icon `ujust update` desktop launcher.

### 🧹 Surgical Debloat (Stripped Down for Pure Desktop)
* **Android / Waydroid** : Completely purged along with binder libraries (`waydroid`, `libgbinder`, `python3-gbinder`).
* **Server Administration** : Purged Cockpit web services and administrative sockets.
* **Handhelds & Laptops** : Purged Steam Deck / ROG Ally / Legion Go daemons (`hhd`, `inputplumber`), Framework laptop modules (`fw-fanctrl`), and mobile APU tools (`ryzenadj`).
* **Heavy Daemons** : Purged resource-heavy snapshot schedulers (`bees`, `snapper`, `btrfs-assistant`) for instant RAM and CPU savings.
* **Extraneous Hardware** : Purged non-AMD GPU drivers (Intel/Nvidia firmwares and media drivers), virtual machine guest agents (QEMU, VMware, VirtualBox, Hyper-V, Spice), and unneeded racing wheel modules.

### 🐚 Shell & Terminal Experience
* **Fish Shell & Starship Prompt** : Configured out-of-the-box with Nerd Fonts (`FiraCode`, `JetBrainsMono`, `Hack`) and clean aliases.
* **Fastfetch** : Custom layout highlighting your Ryzen CPU and Radeon GPU status.
* **Seamless First Run** ([bazzora-firstrun.sh](files/system/etc/profile.d/bazzora-firstrun.sh)) : Automatically sets up Ptyxis terminal profile for Fish on initial launch without blocking `chsh`.

---

## 🛠️ `ujust` Toolkit (Quick Reference)

Bazzora features dedicated, interactive maintenance recipes:

```bash
# Unlock AMD GPU Overdrive (frequencies, undervolt, fan curves in LACT)
ujust toggle-amdgpu-overdrive

# Toggle native Proton Wayland & HDR (or inspect monitor HDR EDID peak nits)
ujust toggle-proton-hdr

# Force global FSR 4 upgrade for supported RDNA 3/4 titles
ujust toggle-fsr4

# Full system update (parallel OSTree, Flatpaks, containers, and brew)
ujust update

# Toggle automated Flatpak installation on boot (silences notification popups)
ujust toggle-flatpak-setup

# Clean unused Flatpaks, Homebrew caches, and rpm-ostree metadata
ujust clean-bazzora

# Restore user configuration files from /etc/skel to $HOME
ujust restore-skel

# Configure firewall ports for GSConnect smartphone pairing
ujust setup-gsconnect

# Install or manage Visual Studio Code via Homebrew
ujust manage-vscode install
```

---

## 🚀 Installation & Deployment

### Option A — Clean Install via Bazzora ISO (USB Drive)
*Recommended for a fresh, optimal bare-metal installation:*

1. **Download** the ISO parts (`bazzora-latest.iso.part*`) and `.CHECKSUM` from the [Releases](https://github.com/0xREAVEN/bazzora/releases) page of this repository.
2. **Recombine** the ISO in your download directory:
   * **Linux / macOS:** `cat bazzora-latest.iso.part* > bazzora-latest.iso`
   * **Windows:** `cmd /c copy /b bazzora-latest.iso.part* bazzora-latest.iso`
3. **Flash** `bazzora-latest.iso` to a USB drive using [Ventoy](https://www.ventoy.net/) (simply copy the `.iso` onto the drive) or [BalenaEtcher](https://etcher.balena.io/).
4. **Boot** your computer from the USB drive and complete the graphical installer.

---

### Option B — Rebase from Bazzite or Fedora Silverblue
*To convert an existing atomic installation without formatting your drive:*

#### 1. Rebase to the initial unverified image
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/0xreaven/bazzora:latest
```

#### 2. Reboot
```bash
systemctl reboot
```

#### 3. Initialize your user environment
> [!NOTE]
> On a fresh ISO install, user accounts receive all configurations automatically.
> Following a rebase, run this one-time command to apply the Bazzora profile and Ptyxis Fish configuration:

```bash
ujust restore-skel
```
*(Choose `M` to copy missing files without overwriting your personal files).*

#### 4. Switch to the cryptographically signed stream (Cosign verified)
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/0xreaven/bazzora:latest
```

#### 5. Final Reboot
```bash
systemctl reboot
```

---

## 🛡️ Atomic Security & Rollback

### Instant System Rollback
If any upstream update introduces an issue, roll back instantly:

* **From the active desktop terminal:**
  ```bash
  rpm-ostree rollback
  systemctl reboot
  ```
* **From the GRUB boot menu:** Select the previous deployment entry to boot directly into your prior working state.

### Image Signature Verification
Verify image authenticity and integrity using Cosign and the public key:
```bash
cosign verify --key cosign.pub ghcr.io/0xreaven/bazzora
```

---

## 📜 License & Credits

Distributed under the **Apache 2.0** license. See [LICENSE](LICENSE) for details.

Special thanks to the open-source projects empowering Bazzora:
* [Fedora Silverblue](https://fedoraproject.org/silverblue/) & [Universal Blue](https://universal-blue.org/)
* [Bazzite](https://bazzite.gg/) for the upstream gaming kernel and Mesa ACO stack
* [BlueBuild](https://blue-build.org/) for declarative containerized OS image builds
* [CachyOS](https://cachyos.org/) for kernel schedulers and gaming sysctl guidelines
* [LACT](https://github.com/ilya-zlobintsev/LACT) for the Linux AMDGPU control and monitoring suite
* [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) & [Papirus Development Team](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) for the desktop styling
