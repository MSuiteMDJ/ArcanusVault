# Build Notes

The active Alpha build produces Arcanus OS installation media:

```text
dist/ArcanusOS-Alpha-x86_64.iso
dist/ArcanusOS-Alpha-x86_64.iso.sha256
```

Main entrypoint:

```bash
sudo build/build-iso.sh
```

Configuration:

```text
build/config/mint-alpha.conf
```

The builder treats Linux Mint XFCE as the upstream base, applies the Arcanus identity layer, regenerates the live filesystem, and repacks a bootable hybrid ISO.
