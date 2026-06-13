# Arcanus ISO Payload

Place all files you want included in the ISO inside this folder.

## Suggested structure:

```
payload/
├── ArcanusLoading.html      # HTML loading page
├── ArcanusLogo.png          # Logo image
├── boot/                    # Boot configuration files
│   └── grub.cfg
├── isolinux/                # ISOLINUX configuration (legacy BIOS)
│   └── isolinux.cfg
└── [other files/dirs]
```

## Build Integration

This directory is used by `build-iso.sh`:
```bash
./build-iso.sh -s payload -o dist/Arcanus.iso --efi-dir efi --force
```

## Notes

- The loading page references branding assets via relative paths
- Logo should be placed at: `payload/Arcanus.Logo.png`
- Keep file sizes reasonable for faster ISO builds
