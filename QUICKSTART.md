# Quick Reference - AV Vault OS Build

## Current Status
- **Phase:** 1 (Minimal Image)
- **Board:** X96Q (Allwinner H313)
- **Base:** Armbian (Debian Trixie)
- **Build Type:** Minimal/Headless

## Quick Commands

### Build
```bash
make build              # Build locally (Linux/Ubuntu only)
make setup              # Prepare build environment
make validate           # Check configuration
make clean              # Clean artifacts
```

### Manual Build
```bash
chmod +x build/build-locally.sh
./build/build-locally.sh
```

### GitHub Actions
Push to `main` branch → automatic build → release uploaded

## Output Artifact
```
AVVaultOS-X96Q-H313-trixie-minimal.img.xz
```
Location: `dist/` (local) or GitHub Releases (CI/CD)

## Flashing to X96Q

### macOS
```bash
diskutil list                    # Find device
diskutil unmountDisk diskX       # Unmount
sudo dd if=image.img of=/dev/rdiskX bs=4m
sudo diskutil ejectDisk diskX
```

### Linux
```bash
lsblk                            # Find device
sudo dd if=image.img of=/dev/sdX bs=4M status=progress
sudo sync
```

## First Boot
```bash
# SSH into device
ssh root@av-vault
# or
ssh root@<ip-address>

# Default password: vault (change immediately)

# Verify AV branding
cat /etc/motd
cat /etc/issue
cat /usr/local/share/av-vault-os/version
```

## Included in Minimal Build
- SSH server (enabled)
- curl, wget, rsync, git
- Storage tools: parted, lsblk, e2fsprogs
- SQLite3
- UTC timezone

## Directories
```
branding/              # Root filesystem overlay
├── rootfs/           # Files to include in image
│   ├── etc/hostname
│   ├── etc/issue
│   ├── etc/motd
│   └── usr/local/share/av-vault-os/version
build/                # Build system
├── armbian-build.sh  # Main build script
├── build-locally.sh  # Local wrapper
└── config/           # Configurations
scripts/              # Helper scripts
```

## Build Times
- First build: 25-40 minutes
- Subsequent builds: 15-25 minutes (with cache)
- Artifact compression: 5-10 minutes

## Troubleshooting
- **Build fails:** Check `tail -f .build/armbian/build-output.log`
- **Image won't boot:** Verify flashing (see Flashing section)
- **SSH not working:** Default user is `root`, password is `vault`
- **Disk space issues:** Build needs 40-50GB free

## Next Phase (Phase 2)
Coming soon: Custom boot splash screen

See [docs/BUILD_PHASES.md](../docs/BUILD_PHASES.md) for full roadmap.
