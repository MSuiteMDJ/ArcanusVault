# Build Guide - AV Vault OS

This document covers building a minimal AV Vault OS image for the X96Q (Allwinner H313).

## Quick Start (GitHub Actions)

The build is fully automated via GitHub Actions. Push to `main` and the image will be built automatically.

**Output:** `AVVaultOS-X96Q-H313-trixie-minimal.img.xz`

Releases are uploaded to the repository's Releases page.

## Local Build (Ubuntu/Linux only)

To build locally:

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
  build-essential git wget bc libncurses5-dev libssl-dev \
  bison flex device-tree-compiler cpio xz-utils u-boot-tools \
  python3 python3-dev dosfstools
```

### Build Steps

```bash
# Make scripts executable
chmod +x build/armbian-build.sh build/build-locally.sh

# Run the build
./build/build-locally.sh
```

The build will:
1. Clone the Armbian repository
2. Apply AV Vault OS branding from `branding/rootfs`
3. Compile the minimal image
4. Compress as `.img.xz`
5. Place the artifact in `dist/`

**Build time:** ~20-40 minutes depending on system

### Build Configuration

Edit `build/config/armbian-config.sh` to customize:

```bash
BOARD="x96q"              # Target board
RELEASE="trixie"          # Debian release
BUILD_MINIMAL="yes"       # Minimal footprint
BUILD_DESKTOP="no"        # No X11/desktop
```

## What's Included in the Minimal Build

### System Tools
- SSH server (enabled by default)
- Git, curl, wget, rsync
- SQLite3
- Parted, lsblk, e2fsprogs
- Timezone/locale support

### AV Branding
- Hostname: `av-vault`
- Login banner from `/etc/issue`
- MOTD from `/etc/motd`
- Version info at `/usr/local/share/av-vault-os/version`

### Boot Configuration
- Serial console: `ttyS0 @ 115200`
- Kernel: Armbian-maintained for H313
- Bootloader: Pre-compiled for X96Q

## Verifying the Build

After build, you can inspect the image:

```bash
# List contents
xz -dc dist/AVVaultOS-X96Q-H313-trixie-minimal.img.xz | \
  fdisk -l /dev/stdin

# Decompress for flashing
xz -d dist/AVVaultOS-X96Q-H313-trixie-minimal.img.xz
```

## Flashing to X96Q

### On macOS

```bash
# Insert USB/SD card, identify device
diskutil list

# Unmount (replace diskX with actual device)
diskutil unmountDisk diskX

# Flash
sudo dd if=AVVaultOS-X96Q-H313-trixie-minimal.img of=/dev/rdiskX bs=4m
sudo diskutil ejectDisk diskX
```

### On Linux

```bash
# Identify device
lsblk

# Unmount
sudo umount /dev/sdX*

# Flash (replace sdX)
sudo dd if=AVVaultOS-X96Q-H313-trixie-minimal.img of=/dev/sdX bs=4M status=progress
sudo sync
```

## Troubleshooting

### Build Fails During Compilation

Check the Armbian build log:

```bash
tail -f .build/armbian/build-output.log
```

Common issues:
- Insufficient disk space (build needs ~30-50GB)
- Missing dependencies (see Prerequisites)
- Network issues pulling packages

### Image Won't Boot

Ensure you're flashing the **correct** device. Bad flashes require re-flashing the bootloader via USB.

### SSH Connection Issues

Default credentials:
- User: `root`
- Password: `vault` (change immediately in production)

Verify SSH is running:

```bash
ssh root@av-vault
# or
ssh root@<ip-address>
```

## Next Steps

After verifying minimal boot:

1. **Level 2:** Custom boot splash/branding
2. **Level 3:** AV Vault Launcher application
3. **Level 4:** Desktop environment + full UI

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/build-image.yml`):

- Triggers on push to `main`
- Runs on Ubuntu runner
- Builds minimal image
- Uploads artifact to Releases
- Tags with build number

## References

- [Armbian Documentation](https://docs.armbian.com/)
- [X96Q Board Info](https://www.armbian.com/x96q/)
- [Allwinner H313 Info](https://linux-sunxi.org/Allwinner_H313)
