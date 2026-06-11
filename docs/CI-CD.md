# CI/CD Architecture

This document describes the GitHub Actions build pipeline for AV Vault OS.

## Pipeline Overview

```
┌─────────────────────────────────────────┐
│  Developer Push to main                 │
│  (branding/, build/, scripts/, etc.)    │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  GitHub Actions Trigger                 │
│  (.github/workflows/build-image.yml)    │
└──────────────────┬──────────────────────┘
                   │
         ┌─────────┴──────────┐
         │                    │
         ▼                    ▼
    ┌─────────────┐     ┌──────────────┐
    │  Ubuntu      │     │  Dependency  │
    │  Setup       │     │  Install     │
    └──────┬───────┘     └──────┬───────┘
           │                    │
           └─────────┬──────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Armbian Clone        │
         │  & Setup              │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Apply AV Branding    │
         │  (rootfs overlay)     │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Armbian Compile      │
         │  x96q/trixie/minimal  │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Verify & Rename      │
         │  Image Artifact       │
         └───────────┬───────────┘
                     │
                     ▼
    ┌────────────────────────────┐
    │  Upload to GitHub Release  │
    │  with build metadata       │
    └────────────────────────────┘
```

## Workflow File

**Location:** `.github/workflows/build-image.yml`

**Triggers:**
- Push to `main` branch
- Changes in: `branding/`, `build/`, `scripts/`, workflow file
- Manual trigger via `workflow_dispatch`

**Runner:** `ubuntu-latest`

## Build Steps

### 1. Checkout & Setup (5 min)
```yaml
- Checkout repository
- Install build dependencies
- Verify git history
```

### 2. Armbian Preparation (5 min)
```yaml
- Clone Armbian repository (shallow clone, ~500MB)
- Create required directories
- Stage build environment
```

### 3. Branding Application (2 min)
```yaml
- Copy branding/rootfs/* → armbian userpatches/overlay
- Enables AV Vault OS hostname, MOTD, version info
```

### 4. Armbian Compilation (15-20 min)
```bash
./compile.sh \
  BOARD=x96q \
  RELEASE=trixie \
  BUILD_MINIMAL=yes \
  BUILD_DESKTOP=no \
  KERNEL_CONFIGURE=no \
  COMPRESS_OUTPUTIMAGE=xz
```

**What Armbian builds:**
- Kernel (pre-compiled, not recompiled)
- Bootloader/U-Boot
- Device tree
- Rootfs from Debian packages
- Applies branding overlay

### 5. Artifact Processing (5 min)
```yaml
- Locate generated .img.xz file
- Rename to: AVVaultOS-X96Q-H313-trixie-minimal.img.xz
- Verify file size (typically 200-300MB)
```

### 6. Release Upload
```yaml
- Create GitHub Release tagged as build-NNN
- Upload .img.xz artifact
- Add build metadata and commit info
```

## Build Times

| Stage | Time | Notes |
|-------|------|-------|
| Setup | 2-3 min | Dependency install |
| Armbian clone | 3-5 min | ~500MB, shallow |
| Branding | 1-2 min | Fast overlay copy |
| Compilation | 15-20 min | Most of build time |
| Artifact | 3-5 min | Compress & verify |
| Upload | 2-3 min | Network dependent |
| **Total** | **~30-40 min** | |

## Environment Variables

Set in workflow (`env:` section):

```yaml
BOARD: x96q
RELEASE: trixie
BUILD_MINIMAL: "yes"
BUILD_DESKTOP: "no"
```

## Artifacts

### Generated on Each Build

**Artifact Name:**
```
AVVaultOS-X96Q-H313-trixie-minimal.img.xz
```

**Size:** ~200-300MB (compressed)

**Format:** XZ-compressed raw disk image

**Location:** GitHub Releases → build-NNN → Assets

### Release Tags

```
build-1    # First build
build-2    # Second build
build-NNN  # Build number N
```

Releases are created automatically and marked as pre-release.

## Accessing Build Artifacts

### Via GitHub Web UI
1. Go to repository "Releases"
2. Click on `build-NNN` release
3. Download `AVVaultOS-X96Q-H313-trixie-minimal.img.xz`

### Via GitHub CLI
```bash
gh release download build-1 --pattern "*.img.xz"
```

### Direct Download
```bash
# Example for build-1
wget https://github.com/neiljones232new/ArcanusVaultOS/releases/download/build-1/AVVaultOS-X96Q-H313-trixie-minimal.img.xz
```

## Build Logs

Complete build logs are available in:

1. **GitHub Actions UI:**
   - Go to "Actions" tab
   - Click on workflow run
   - View real-time logs or download

2. **Artifacts in Release:**
   - Download `build.log` from release (future enhancement)

## Configuration Changes

To change build parameters:

1. Edit `.github/workflows/build-image.yml`
2. Update `env:` section:
   ```yaml
   env:
     BOARD: x96q
     RELEASE: trixie    # Change release
     BUILD_MINIMAL: "yes"
     BUILD_DESKTOP: "no"
   ```
3. Commit and push to `main`
4. New build starts automatically

## Manual Trigger

To build without code changes:

```bash
gh workflow run build-image.yml \
  -f upload_artifacts=true
```

Or via GitHub UI:
- Go to "Actions" → "Build AV Vault OS Image"
- Click "Run workflow"

## Caching

Build cache is **intentionally disabled** (`ARTIFACT_IGNORE_CACHE=yes`) for consistency.

Future optimization: Implement package cache to speed up subsequent builds.

## Failure Handling

On build failure:

1. **Workflow Status:** Red ✗
2. **Notification:** GitHub email alert
3. **Logs:** Available in Actions tab
4. **No Release Created:** Prevents broken artifacts

Common failures:
- Network timeout (retry)
- Disk space (increase runner size)
- Armbian changes (update branch)

## Multi-Platform Future

**Phase 4** will extend to:

```yaml
strategy:
  matrix:
    board: [x96q, rpi5, intel]
    
jobs:
  build-matrix:
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ matrix.board }}
```

Each board builds in parallel, outputs:
- `AVVaultOS-X96Q-trixie-minimal.img.xz`
- `AVVaultOS-RPi5-trixie-minimal.img.xz`
- `AVVaultOS-Intel-trixie-minimal.img.xz`

## Security

Current setup:
- ✓ No secrets required
- ✓ No external API calls
- ✓ Source verified (repo default branch)
- ✓ Artifacts signed (future: GPG)

## Cost Analysis

GitHub Actions free tier includes:
- 2,000 free minutes per month
- Build time: ~30-40 min/run
- **Can run ~50 builds/month free**

Sufficient for development + weekly releases.

## Monitoring & Metrics

Future enhancements:
- Build time trend graph
- Success/failure rate
- Artifact size tracking
- Release download analytics

See [BUILD_PHASES.md](BUILD_PHASES.md#phase-4-github-actions-build-pipeline) for Phase 4 details.
