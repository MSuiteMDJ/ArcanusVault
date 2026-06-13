# Arcanus ISO Build - Quick Checklist
#
# Use this to track your ISO build setup progress.

## Directory Structure ✅
- [x] payload/ directory created
- [x] payload/README.md created
- [x] efi/ directory created
- [x] efi/EFI/BOOT/ directory created
- [x] efi/isolinux/ directory created
- [x] Placeholder .gitkeep files in place

## Content Files ✅
- [x] payload/ArcanusLoading.html created
- [x] efi/README.md created
- [x] efi/EFI/BOOT/README.md created
- [x] ISO_BUILD_SETUP.md guide created

## Required Actions (TODO)
- [ ] Copy logo: `cp ArcanusLogo.png payload/Arcanus.Logo.png`
- [ ] Obtain BOOTX64.EFI bootloader → `efi/EFI/BOOT/BOOTX64.EFI`
- [ ] Create ISOLINUX config → `efi/isolinux/isolinux.cfg`
- [ ] Test build with dry-run: `./build-iso.sh -s payload -o test.iso -n -v`
- [ ] Build ISO: `./build-iso.sh -s payload -o dist/Arcanus.iso --efi-dir efi --force`

## Documentation
- [ISO_BUILD_SETUP.md](ISO_BUILD_SETUP.md) — Complete setup guide
- [payload/README.md](payload/README.md) — Payload directory guide
- [efi/README.md](efi/README.md) — EFI System Partition details
