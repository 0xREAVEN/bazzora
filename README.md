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

It bridges the gap between the **gaming stack inherited from Bazzite** (gaming kernel, 32/64-bit Mesa RADV/ACO, ZRAM, NTSYNC module, FSR 4 upgrade) and the **rock-solid sobriety of vanilla Fedora Silverblue** — completely stripping away mobile console daemons, unneeded hypervisor modules, Android subsystems, and desktop bloatware.

---

## ⚖️ Why Bazzora? (Comparison)

| Feature | Vanilla Silverblue | Default Bazzite | **Bazzora** |
| :--- | :---: | :---: | :---: |
| **Gaming Kernel (Bazzite / OGC)** | ❌ (Stock generic) | ✅ | ✅ **Inherited** |
| **Mesa RADV ACO (32 & 64-bit)** | ✅ (Fedora build) | ✅ | ✅ **Inherited** |
| **Mesa XXL Shader Cache (50 GB anti-stutter)** | ❌ (Default 1 GB) | ❌ (Default 1 GB) | ✅ **Yes (50 GB)** |
| **Proton Wayland & Native HDR (Mutter Direct)** | ❌ | ⚠️ (Gamescope only) | ✅ **Yes (`ujust`)** |
| **Proton NTSYNC Kernel Fastpath** | ❌ | ⚠️ (Module loaded, Proton variable manual) | ✅ **`PROTON_USE_NTSYNC=1` by default** |
| **AMD GPU Overdrive & LACT (Undervolt/Fans)** | ❌ | ⚠️ (Flatpak, manual sudo) | ✅ **Native RPM + `lactd` daemon** |
| **Disk Partitioning Suite** | ❌ (Disks only) | ❌ (Disks only) | ✅ **GParted (Native RPM)** |
| **Audio Crackle Guard (PipeWire min-quantum)** | ❌ (min 32) | ❌ (min 32) | ✅ **Min 256** |
| **Gaming Sysctl Tuning** | ❌ | ⚠️ (`max_map_count`, BBR, ZRAM zstd) | ✅ **+ swappiness, dirty limits, `fq`** |
| **Mutter VRR & XWayland Native Scaling** | ❌ | ❌ | ✅ **Unlocked (VRR per display)** |
| **Clean Vanilla Desktop (Zero bloatware extensions)**| ✅ | ❌ (Compiz effects / Docks) | ✅ **Pure GNOME** |
| **Default Aesthetics (Bibata Ice & Papirus-Dark)** | ❌ (Adwaita) | ❌ (Adwaita) | ✅ **Bibata Modern Ice + Papirus** |
| **Android / Waydroid Subsystem** | ❌ | ⚠️ (Bundled) | 🚫 **Completely purged** |
| **Handheld / Steam Deck Extras** | ❌ | ⚠️ (Deck presets & tools) | 🚫 **Purged** |
| **Server Administration Stack (Cockpit)** | ❌ | ⚠️ (Installed, inactive) | 🚫 **Purged & masked** |

---

## ⚡ Core Features & Optimizations

### 🎮 Full AMD High-Performance Gaming Stack
* **RADV Vulkan with ACO Compiler** : 32 and 64-bit Mesa inherited from Bazzite.
* **XXL Mesa Shader Cache (50 GB)** : Preconfigured via [10-amd-gaming.conf](files/system/etc/environment.d/10-amd-gaming.conf) (`MESA_SHADER_CACHE_MAX_SIZE=50G`) to keep compiled shaders instead of evicting them at Mesa's default 1 GB limit (up to 50 GB of disk in `~/.cache`).
* **Proton NTSYNC Fastpath** : `PROTON_USE_NTSYNC=1` enabled out of the box for ultra-low overhead Windows NT synchronization.
* **AMD GPU Services (AGS) & FSR 4 Ready** : `PROTON_ENABLE_AMD_AGS=1` enabled for native FidelityFX features, with Bazzite's global FSR 4 upgrade available via `ujust global-fsr4` (RDNA 4).
* **Proton Wayland & Native HDR** : Command `ujust toggle-proton-hdr` enables native Wayland rendering and direct Mutter HDR passthrough without the compositing overhead or color banding of nested Gamescope.
* **LACT Native RPM + Auto-Started `lactd` Daemon** : AMD GPU control panel (overclocking, undervolting, custom fan curves) packaged natively via official COPR. The `lactd.service` runs as a system daemon on boot, enabling immediate hardware control without requiring root passwords.
* **One-Click AMD Overdrive** : `ujust toggle-amdgpu-overdrive` adds only the overdrive bit (`0x4000`) to the driver's `amdgpu.ppfeaturemask`, the same method Bazzite uses on handhelds.

### ⚙️ Kernel & System Tuning (CachyOS & SteamOS Standards)
* **Inherited from Bazzite** (not redefined): `vm.max_map_count = 2147483642`, TCP `bbr` congestion control, ZRAM with zstd compression, `ntsync` module loaded at boot.
* **Gaming Memory & Swappiness Profile** ([99-bazzora-gaming.conf](files/system/etc/sysctl.d/99-bazzora-gaming.conf)):
  * `vm.swappiness = 100` (kernel default: 60), suited to Bazzite's ZRAM swap.
  * `dirty_bytes` limits (256 MB dirty / 64 MB background) to write data back in smaller batches, with a 15 s write-back interval. Kept in the `performance` power mode through a Bazzora tuned profile ([throughput-performance-bazzora](files/system/usr/lib/tuned/profiles/throughput-performance-bazzora/tuned.conf)).
  * `fq` packet pacing (Fedora default: `fq_codel`). BBR, provided by Bazzite, only applies to TCP, not to the UDP traffic most online games use.
* **Transparent Hugepages (THP) Defrag** ([bazzora-thp.conf](files/system/etc/tmpfiles.d/bazzora-thp.conf)):
  * `defrag` set to `defer+madvise` (THP itself stays in the kernel's `madvise` mode) and `khugepaged/max_ptes_none = 409`.
* **Audio Crackle Guard** ([10-bazzora-gaming.conf](files/system/etc/pipewire/pipewire.conf.d/10-bazzora-gaming.conf)):
  * PipeWire `min-quantum = 256`: applications can no longer request buffers below 256 samples (≈ 5.3 ms at 48 kHz), which reduces crackling under heavy CPU load such as shader compilation. The default quantum stays at 1024: this is not a latency reduction.
* **Watchdogs kept** as on Bazzite (recovery after a hard lockup); `ujust configure-watchdog` turns them off.

### 🖥️ Clean GNOME Environment & Modern Styling
* **Mutter Gaming Tweaks**:
  * Variable Refresh Rate (VRR / FreeSync), `scale-monitor-framebuffer` and `xwayland-native-scaling` experimental features unlocked. VRR is then enabled per display in Settings › Displays.
  * Bazzite's 20 s *"Application is not responding"* timeout is kept: long loading screens are tolerated and frozen apps can still be force-quit.
  * Flat mouse acceleration curve (`accel-profile='flat'`) for raw 1:1 precision competitive aim.
* **Default Aesthetics**:
  * **Cursor Theme** : **Bibata Modern Ice** installed system-wide (`/usr/share/icons/default/index.theme`, GNOME, GTK 3 & GTK 4, Flatpaks, XWayland).
  * **Icon Theme** : **Papirus-Dark** providing clean, high-contrast monochrome system panel icons alongside colorful app icons.
  * **GTK Theme** : Dark mode by default (`adw-gtk3-dark` + `color-scheme='prefer-dark'`).
* **Clean Productivity**:
  * Pre-packaged **GParted** for advanced drive management.
  * **ExtensionManager** installed in Flatpak to manage user extensions safely.
  * Useful shortcuts: `Ctrl+Alt+T` (Ptyxis terminal) and `Ctrl+Shift+Esc` (Mission Center).
  * Purged KDE-based updater in favor of the lightweight, yellow-icon `ujust bazzora-update` desktop launcher.

### 🧹 Surgical Debloat (Stripped Down for Pure Desktop)
* **Android / Waydroid** : Completely purged along with binder libraries (`waydroid`, `libgbinder`, `python3-gbinder`).
* **Server Administration** : Purged Cockpit packages (installed but inactive on Bazzite) and masked `cockpit.socket` / `cockpit.service`.
* **Handhelds & Laptops** : No handheld daemons (`hhd`, `inputplumber` are not part of the desktop base), purged Framework laptop modules (`fw-fanctrl`), and mobile APU tools (`ryzenadj`).
* **Snapshot Tools** : Purged `bees`, `snapper` and `btrfs-assistant`. They are not enabled by default on Bazzite: this frees disk space and attack surface, not RAM or CPU at runtime.
* **Extraneous Hardware** : Purged Intel/Nvidia GPU firmwares and Intel media drivers (Mesa itself is unchanged), virtual machine guest agents (QEMU, VMware, VirtualBox, Hyper-V, Spice), and racing wheel drivers (Fanatec, Thrustmaster, Logitech `new-lg4ff`).
* **Also removed — check before installing** : accessibility stack (Orca screen reader, braille `brltty`, speech synthesis), Broadcom Wi-Fi drivers (`broadcom-wl`, `b43`), DisplayLink (`evdi`), Razer peripherals (`openrazer`), Looking Glass (`kvmfr`), HDMI-CEC, fingerprint reader, Lutris, Fish and Yelp. Full list in [recipe.yml](recipes/recipe.yml).

### 🐚 Shell & Terminal Experience
* **Bash, bash-completion & Starship Prompt** : Configured out-of-the-box with Nerd Fonts (`FiraCode`, `JetBrainsMono`, `Hack`).
* **Fastfetch** : Custom layout highlighting your Ryzen CPU and Radeon GPU status.
* **Seamless First Run** ([bazzora-firstrun.sh](files/system/etc/profile.d/bazzora-firstrun.sh)) : Applies Bazzora configs and resets the Ptyxis profile to the login shell (Bash) on first launch.

---

## 🛠️ `ujust` Toolkit (Quick Reference)

Bazzora features dedicated, interactive maintenance recipes:

```bash
# Unlock AMD GPU Overdrive (frequencies, undervolt, fan curves in LACT)
ujust toggle-amdgpu-overdrive

# Toggle native Proton Wayland & HDR (or inspect monitor HDR EDID peak nits)
ujust toggle-proton-hdr

# Force global FSR 4 upgrade for supported RDNA 4 titles (Bazzite recipe)
ujust global-fsr4

# Full system update (parallel OSTree, Flatpaks, containers, and brew)
ujust bazzora-update

# Check system health and gaming settings (read-only)
ujust bazzora-doctor

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

> Bazzite recipes irrelevant to a Full AMD desktop (Steam Deck, Decky, Framework, Nvidia, Intel, CEC…) are hidden from the list.
> They remain callable by name. See [`ujust-masked.list`](files/system/usr/share/bazzora/ujust-masked.list).

---

## 🚀 Installation & Deployment

### Option A — Clean Install via Bazzora ISO (USB Drive)
*Recommended for a fresh, optimal bare-metal installation:*

1. **Download** the ISO parts (`bazzora-latest.iso.part*`) and `bazzora-latest.iso-CHECKSUM` from the [Releases](https://github.com/0xREAVEN/bazzora/releases) page of this repository.
2. **Recombine** the ISO in your download directory, then check it against the checksum file:
   * **Linux / macOS:** `cat bazzora-latest.iso.part* > bazzora-latest.iso && sha256sum -c bazzora-latest.iso-CHECKSUM`
   * **Windows:** `cmd /c copy /b bazzora-latest.iso.part* bazzora-latest.iso`, then compare `Get-FileHash bazzora-latest.iso -Algorithm SHA256` with the checksum file
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
> Following a rebase, run this one-time command to apply the Bazzora profile and Ptyxis configuration:

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

### Pinned Fallback Deployment
Before every update, `ujust bazzora-update` **pins the currently booted deployment** (the one that works).
It stays available in the boot menu even after several failed updates in a row.
Only one Bazzora pin exists at a time, and your manual pins (`ostree admin pin`) are never touched.

### Tested Releases
Every build is first published under the `candidate` tag, then goes through automated smoke tests run inside a container
(no boot, no GPU): `bootc` compliance, `ujust` loading, removed/added packages, services (LACT, masked Cockpit),
configuration files, GSettings schemas and Cosign signature. The image only becomes `latest` if **all** tests pass.
Otherwise you stay on the last validated release.

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
* [Bazzite](https://bazzite.gg/) for the upstream gaming kernel, Mesa stack, ZRAM and sysctl base
* [BlueBuild](https://blue-build.org/) for declarative containerized OS image builds
* [CachyOS](https://cachyos.org/) for kernel schedulers and gaming sysctl guidelines
* [LACT](https://github.com/ilya-zlobintsev/LACT) for the Linux AMDGPU control and monitoring suite
* [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) & [Papirus Development Team](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) for the desktop styling
