# Arcanus Vault OS

Arcanus Vault OS is a branded, offline operating platform prototype for the X96Q H313 demo hardware. The prototype is designed to sit on top of a delivered Armbian image rather than forking Armbian or maintaining a custom kernel.

The goal is to make the image feel like a product immediately:

```text
Power On
-> ARCANUS VAULT OS
-> Desktop
-> AV Vault Launcher
```

## Prototype Scope

Level 1 branding is the default target for the first image:

- Hostname: `av-vault`
- Login banner
- MOTD
- Wallpaper placeholder
- Boot splash placeholder
- Version information

The first demo build identifies itself as:

```text
Arcanus Vault OS
Version: Prototype 0.1
Platform: X96Q H313
Mode: Airgapped
```

## Platform Layout

```text
Platform
└─ AV Vault OS

Applications
├─ AV Ledger
├─ AV Records
├─ AV Assets
└─ AV Evidence
```

## Branding Overlay

The repo contains a root filesystem overlay in `branding/rootfs` and an installer script:

```bash
sudo scripts/apply-branding.sh /mnt/armbian-rootfs
```

The script writes the prototype hostname, MOTD, login banner, version file, and a lightweight terminal launcher command without changing the kernel or Armbian build system.

After applying the overlay, this should work inside the image:

```bash
cat /etc/motd
av-vault-launcher
```

## Build Artifacts

Longer term, the pipeline should emit branded artifact names:

```text
AVVaultOS-X96Q.img.xz
AVVaultOS-Intel.img.xz
AVVaultOS-RPi5.img.xz
```

The current prototype target is:

```text
AVVaultOS-X96Q-Prototype-0.1.img.xz
```

## Build System

The build uses **Armbian as the base** with AV Vault OS customizations layered on top. No custom kernel compilation needed.

### Quick Build (GitHub Actions)

Builds trigger automatically on push to `main`. Artifacts are released as:

```text
AVVaultOS-X96Q-H313-trixie-minimal.img.xz
```

### Local Build (Linux/Ubuntu)

```bash
chmod +x build/build-locally.sh
./build/build-locally.sh
```

See [BUILD.md](docs/BUILD.md) for detailed instructions, flashing guides, and troubleshooting.

### Build Phases

The project follows a four-phase progression:

1. **Phase 1 (Now):** Minimal bootable image with AV branding
2. **Phase 2:** Custom boot splash screen
3. **Phase 3:** AV Vault Launcher application
4. **Phase 4:** Multi-platform CI/CD

See [BUILD_PHASES.md](docs/BUILD_PHASES.md) for the detailed roadmap.

## Roadmap

- Phase 1: Simple branding overlay → minimal bootable image
- Phase 2: Replace Armbian boot text with Arcanus Vault OS branding
- Phase 3: Desktop login launches AV Vault Launcher
- Phase 4: GitHub Actions pipeline with multi-platform support
