# Build Phases

This document outlines the four-phase build progression for AV Vault OS.

## Phase 1: Minimal Image (Current)

**Target:** Bootable, branded X96Q image without desktop

**Deliverables:**
- Bootable Armbian minimal image
- AV branding applied (hostname, MOTD, version)
- SSH enabled
- Storage/filesystem tools
- No GUI

**Build:** `AVVaultOS-X96Q-H313-trixie-minimal.img.xz`

**Success Criteria:**
✓ Image boots to login prompt
✓ SSH connection works
✓ MOTD displays "Arcanus Vault OS"
✓ Hostname is `av-vault`
✓ Storage tools functional

---

## Phase 2: Custom Boot Branding

**Target:** Replace Armbian boot text with AV branding

**Deliverables:**
- Custom splash screen
- Boot messages branded as "ARCANUS VAULT OS"
- X96Q H313 specific boot logo
- Bootloader customization

**Build Command:**
```bash
./compile.sh BOARD=x96q RELEASE=trixie BUILD_DESKTOP=no BUILD_MINIMAL=yes BOOT_BRANDING=yes
```

**Artifacts to Create:**
- `build/boot/splash.png`
- `build/boot/bootlogo.txt`
- `build/config/boot-config.sh`

**Success Criteria:**
✓ Boot shows "ARCANUS VAULT OS" logo
✓ No Armbian branding visible
✓ Boots to login in < 30 seconds

---

## Phase 3: AV Vault Launcher

**Target:** Terminal/GUI launcher for AV Vault applications

**Deliverables:**
- Desktop application launcher
- Menu options for future apps
- Settings interface
- Graceful shutdown

**Build Components:**
- `scripts/av-vault-launcher` → GUI version
- Desktop environment (lightweight: LXDE/Openbox)
- `.desktop` entry for launcher

**Build Command:**
```bash
./compile.sh BOARD=x96q RELEASE=trixie BUILD_DESKTOP=yes BUILD_LAUNCHER=yes BUILD_MINIMAL=no
```

**Menu Options:**
```
┌─────────────────────┐
│  ARCANUS VAULT OS   │
├─────────────────────┤
│ ▶ AV Ledger         │
│ ▶ AV Records        │
│ ▶ AV Assets         │
│ ▶ AV Evidence       │
├─────────────────────┤
│ ⚙ Settings          │
│ ⏻ Shutdown          │
└─────────────────────┘
```

**Success Criteria:**
✓ Desktop boots automatically on login
✓ Launcher displays cleanly
✓ Menu navigation works
✓ Applications can be selected (stubs OK for now)

---

## Phase 4: GitHub Actions Build Pipeline

**Target:** Fully automated build and release pipeline

**Deliverables:**
- GitHub Actions workflow
- Automated testing
- Versioned releases
- Multi-platform support (future)

**Releases:**
```
AVVaultOS-X96Q-H313-trixie-minimal.img.xz
AVVaultOS-X96Q-H313-trixie-desktop.img.xz
AVVaultOS-X96Q-H313-trixie-full.img.xz
```

**Future Platforms:**
```
AVVaultOS-RPi5-trixie-minimal.img.xz
AVVaultOS-Intel-trixie-minimal.img.xz
```

**CI/CD Pipeline:**
1. Commit → main
2. GitHub Actions triggers
3. Build image (parallel for multi-platform)
4. Run validation tests
5. Upload to Releases
6. Create GitHub Release notes

**Success Criteria:**
✓ Builds trigger automatically
✓ Artifacts upload to Releases
✓ Build time < 60 minutes
✓ Consistent artifact naming

---

## Timeline Recommendation

| Phase | Effort | Timeline | Blocker |
|-------|--------|----------|---------|
| 1 | Low | Week 1 | None |
| 2 | Medium | Week 2 | Phase 1 working |
| 3 | High | Weeks 3-4 | Phase 2 complete |
| 4 | Low | Week 4 | Phase 3 in progress |

---

## Technical Decisions

### Why Armbian Base?
- Pre-built kernel for H313
- Bootloader already configured
- Minimal maintenance burden
- Community support

### Why Minimal First?
- Faster to debug boot issues
- Smaller image for testing
- Desktop added without bootloader risks
- Clear validation checkpoint

### Why GitHub Actions?
- No self-hosted runners needed
- Free tier sufficient for images
- Artifact storage via Releases
- Future: multi-platform CI/CD

---

## Rollback Strategy

If a phase fails:

1. **Phase 1 fails:** Fix Armbian configuration, restart build
2. **Phase 2 fails:** Keep Phase 1 image, iterate boot configs
3. **Phase 3 fails:** Keep Phase 2 image, debug launcher separately
4. **Phase 4 fails:** Manual builds OK, automate incrementally

Each phase produces a **stable artifact** that can ship independently.
