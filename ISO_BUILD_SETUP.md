# Arcanus ISO Build Infrastructure Setup

## ✅ Completed Structure

```
/
├── payload/                          # ISO Content Root
│   ├── README.md                     # Documentation
│   ├── ArcanusLoading.html          # Boot loading page
│   └── [files to include in ISO]
│
├── efi/                              # UEFI/EFI System Partition
│   ├── README.md                     # Documentation
│   ├── EFI/BOOT/
│   │   ├── .gitkeep                 # Placeholder (awaiting BOOTX64.EFI)
│   │   └── README.md                # Bootloader instructions
│   └── isolinux/                    # Legacy BIOS boot
│       ├── .gitkeep                 # Placeholder
│       └── isolinux.cfg.template    # Configuration template
│
└── build-iso.sh                      # ISO builder (ready to use)
```

## 🎯 Build Command

```bash
./build-iso.sh \
  -s payload \
  -o dist/Arcanus.iso \
  --efi-dir efi \
  -l Arcanus \
  --force \
  -v
```

## 📋 Next Steps (TODO)

### 1. **Add Logo to Payload**
Copy the logo to `payload/`:
```bash
cp ArcanusLogo.png payload/Arcanus.Logo.png
```
The HTML file already references this path.

### 2. **Add EFI Bootloader**
Obtain `BOOTX64.EFI` and place at: `efi/EFI/BOOT/BOOTX64.EFI`

**Sources:**
- Extract from upstream Linux Mint ISO
- GRUB EFI binaries
- systemd-boot

### 3. **Configure ISOLINUX (Legacy BIOS)**
Create `efi/isolinux/isolinux.cfg` from template:
```bash
cp efi/isolinux/isolinux.cfg.template efi/isolinux/isolinux.cfg
```
Then customize kernel/initrd references.

### 4. **Test Build**
```bash
./build-iso.sh -s payload -o dist/test.iso -l Arcanus -v -n
```
Use `-n` for dry-run first.

## 📚 Key Files Reference

| File | Purpose | Status |
|------|---------|--------|
| `build-iso.sh` | ISO builder script | ✅ Ready |
| `payload/README.md` | Documentation | ✅ Complete |
| `efi/README.md` | Documentation | ✅ Complete |
| `payload/ArcanusLoading.html` | Boot loading page | ✅ Complete |
| `payload/Arcanus.Logo.png` | Loading page logo | ⏳ Copy needed |
| `efi/EFI/BOOT/BOOTX64.EFI` | UEFI bootloader | ⏳ Obtain + place |
| `efi/isolinux/isolinux.cfg` | BIOS boot config | ⏳ Create from template |

## 🔧 Build Script Features

- ✅ Cross-platform (Linux/macOS/Windows)
- ✅ UEFI + BIOS boot support
- ✅ El Torito hybrid mode
- ✅ Reproducible builds (SOURCE_DATE_EPOCH)
- ✅ Dry-run mode (`-n`)
- ✅ Verbose logging (`-v`)

## 📖 Documentation

See also:
- `efi/README.md` — EFI System Partition details
- `payload/README.md` — Payload directory guide
- `build-iso.sh --help` — Full usage

---

**Status:** Scaffold complete. Ready for media content and bootloaders.
