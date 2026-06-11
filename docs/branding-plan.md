# AV Vault OS Branding Plan

## Level 1 - Simple Branding

Level 1 brands the delivered image without changing the kernel or forking Armbian.

- Hostname: `av-vault`
- Login banner: `/etc/issue`
- MOTD: `/etc/motd`
- Version information: `/usr/local/share/av-vault-os/version`
- Launcher command: `/usr/local/bin/av-vault-launcher`
- Wallpaper and boot splash placeholders for later image-specific work

## Level 2 - Custom Boot Screen

Replace visible `Armbian` boot branding with `Arcanus Vault OS` where the target image exposes splash assets or boot text configuration.

The demo boot story should read:

```text
Power On
-> ARCANUS VAULT OS
```

## Level 3 - AV Launcher

On desktop login, launch the AV Vault Launcher with:

```text
Open AV Ledger
Open AV Records
Open AV Assets
Open AV Evidence
Settings
Shutdown
```

The prototype includes a terminal launcher stub so the product flow is visible before the desktop application exists.

## Level 4 - Build Pipeline Branding

GitHub Actions should package image artifacts as:

```text
AVVaultOS-X96Q.img.xz
AVVaultOS-Intel.img.xz
AVVaultOS-RPi5.img.xz
```

For the current prototype:

```text
AVVaultOS-X96Q-Prototype-0.1.img.xz
```
