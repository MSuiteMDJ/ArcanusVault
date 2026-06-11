# Build Environment Setup

This document describes the build environment requirements and setup for AV Vault OS.

## Supported Environments

### GitHub Actions (Recommended)
- **Runner:** Ubuntu latest
- **Trigger:** Push to `main` branch
- **Artifacts:** Released automatically
- **Time:** ~25-30 minutes
- **Cost:** Free (GitHub included)

### Local Build (Linux/Ubuntu)
- **OS:** Ubuntu 20.04 LTS or newer
- **RAM:** 8GB minimum (16GB recommended)
- **Disk:** 50GB free space
- **Internet:** High-speed connection
- **Time:** ~30-40 minutes
- **Cost:** Your machine

### Not Supported
- ❌ macOS (Armbian build system requires Linux-specific tools)
- ❌ Windows (use WSL2 with Ubuntu)
- ❌ Docker (possible, but complex for image builds)

## Local Build Prerequisites

### Install Ubuntu

If building locally, ensure you have Ubuntu 20.04 LTS or newer:

```bash
lsb_release -a
```

### Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  git \
  wget \
  bc \
  libncurses5-dev \
  libssl-dev \
  bison \
  flex \
  device-tree-compiler \
  cpio \
  xz-utils \
  u-boot-tools \
  python3 \
  python3-dev \
  dosfstools
```

### Verify Installation

```bash
# Check key tools
which gcc git wget make
gcc --version
git --version

# Should output version info for each
```

## Storage Requirements

The build process uses approximately:

```
├── Armbian repo clone:      ~5GB
├── Build cache/sources:     ~10GB
├── Kernel compilation:      ~15GB
├── Rootfs assembly:         ~5GB
├── Final image (compressed): ~200MB
└── Total needed:            ~50GB free
```

**Recommendation:** Ensure 60GB free to be safe.

Check available space:

```bash
df -h /path/to/build
# or for current directory
du -sh .
```

## Network Requirements

The build downloads:
- Armbian repository: ~500MB
- Kernel sources: ~300MB
- Build tools/packages: ~1-2GB

**Minimum:** 1 Mbps sustained
**Recommended:** 10+ Mbps for faster builds

## GitHub Actions Secrets

No secrets are required for basic builds. For future enhancements:

```yaml
# Optional for private releases
GITHUB_TOKEN: (auto-provided by GitHub)
```

## Directory Structure

After setup, your workspace will have:

```
Arcanus Vault OS/
├── .github/workflows/
│   └── build-image.yml      # CI/CD pipeline
├── build/
│   ├── armbian-build.sh     # Main build script
│   ├── build-locally.sh     # Local wrapper
│   ├── config/
│   │   └── armbian-config.sh # Build configuration
│   └── .build/              # (created during build)
│       └── armbian/         # Armbian clone
├── branding/
│   └── rootfs/              # Overlay to apply
├── dist/                    # (created on build)
│   └── *.img.xz            # Final artifact
└── scripts/
    └── apply-branding.sh
```

## Environment Variables

Optional configuration:

```bash
# Custom Armbian repo
export ARMBIAN_REPO="https://github.com/yourusername/armbian-fork.git"

# Custom build directory
export BUILD_DIR="/mnt/large-disk/.build"

# Skip certain build steps
export SKIP_KERNEL_COMPILE=yes
```

## Makefile Commands

Once dependencies are installed:

```bash
make help              # Show all available commands
make install-deps      # Verify dependencies
make validate          # Check configuration
make setup             # Prepare environment
make build             # Run full build
make clean             # Clean artifacts
```

## Troubleshooting Build Environment

### "gcc: command not found"
```bash
sudo apt-get install build-essential
```

### "Armbian script not found"
Verify `.build/armbian` exists and `compile.sh` is executable:
```bash
ls -la .build/armbian/compile.sh
chmod +x .build/armbian/compile.sh
```

### "Not enough space" during build
Move build directory to larger volume:
```bash
export BUILD_DIR=/mnt/larger-disk/.build
./build/build-locally.sh
```

### Network timeout during download
Check connection and retry:
```bash
# Reduce parallelism
export BUILD_JOBS=2
./build/build-locally.sh
```

## GitHub Actions Environment

The CI/CD uses Ubuntu latest with pre-installed tools:

```yaml
runs-on: ubuntu-latest
```

All required dependencies are installed in the workflow. No setup needed.

## Performance Tips

### Faster Builds
```bash
# Use local SSD if available
export BUILD_DIR=/mnt/nvme/.build

# Enable build caching
export ARTIFACT_IGNORE_CACHE=no  # Use cache

# Increase parallelism
export BUILD_JOBS=8
```

### Monitor Build Progress
```bash
# In another terminal, watch the log
tail -f .build/armbian/build-output.log

# Check disk usage
du -sh .build/
```

## Next Steps

After environment is ready:

1. Run validation: `make validate`
2. Start build: `make build`
3. Monitor progress: `tail -f .build/armbian/build-output.log`
4. Find artifact: `ls -lh dist/*.img.xz`

See [BUILD.md](BUILD.md) for build instructions.
