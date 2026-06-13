# Arcanus EFI System Partition

This directory contains files that will be packaged into an EFI System Partition image for ISO boot support.

## Structure:

```
efi/
├── EFI/BOOT/
│   ├── BOOTX64.EFI          # x86_64 UEFI bootloader
│   └── BOOTAA64.EFI         # ARM64 UEFI bootloader (optional)
├── isolinux/                # Legacy BIOS boot support
│   ├── isolinux.bin
│   └── isolinux.cfg
└── [boot files]
```

## Boot Loaders

### UEFI (x86_64)
- **File:** `EFI/BOOT/BOOTX64.EFI`
- **Source:** Obtain from bootloader project or OVMF firmware
- **Size:** Typically 500KB - 2MB

### BIOS (Legacy)
- **File:** `isolinux/isolinux.bin`
- **Source:** ISOLINUX boot files
- **Used for:** BIOS-era systems without UEFI

## Build Integration

The build-iso.sh script uses this directory to create EFI System Partition:
```bash
./build-iso.sh -s payload -o dist/Arcanus.iso --efi-dir efi --force
```

The `--efi-size-mb` parameter can be specified to customize the partition size (default: auto-calculated).

## References

- UEFI Spec: https://uefi.org/
- ISOLINUX: https://wiki.syslinux.org/wiki/index.php/ISOLINUX
