#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0
WARNINGS=0

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

pass() {
  echo -e "${GREEN}OK${NC} $1"
}

warn() {
  echo -e "${YELLOW}WARN${NC} $1"
  WARNINGS=$((WARNINGS + 1))
}

fail() {
  echo -e "${RED}FAIL${NC} $1"
  ERRORS=$((ERRORS + 1))
}

require_file() {
  local path="$1"
  [[ -f "$PROJECT_ROOT/$path" ]] && pass "$path" || fail "$path missing"
}

require_dir() {
  local path="$1"
  [[ -d "$PROJECT_ROOT/$path" ]] && pass "$path" || fail "$path missing"
}

contains() {
  local path="$1"
  local text="$2"
  if [[ -f "$PROJECT_ROOT/$path" ]] && grep -q "$text" "$PROJECT_ROOT/$path"; then
    pass "$path contains '$text'"
  else
    fail "$path does not contain '$text'"
  fi
}

echo "Arcanus OS Alpha - scaffold verification"
echo "========================================"
echo

echo "Project structure"
echo "-----------------"
for dir in \
  "branding/boot" \
  "branding/login" \
  "branding/wallpapers" \
  "branding/icons" \
  "branding/logos" \
  "branding/rootfs" \
  "theme/Arcanus-Dark" \
  "control-centre" \
  "build/mint" \
  "docs"; do
  require_dir "$dir"
done
echo

echo "Branding assets"
echo "---------------"
require_file "branding/logos/arcanus-logo.png"
require_file "branding/boot/arcanus/arcanus-logo.png"
require_file "branding/boot/arcanus/arcanus.plymouth"
require_file "branding/boot/arcanus/arcanus.script"
require_file "branding/login/arcanus-login-wallpaper.png"
require_file "branding/wallpapers/arcanus-alpha-wallpaper.png"
echo

echo "Rootfs overlay"
echo "--------------"
require_file "branding/rootfs/etc/os-release"
require_file "branding/rootfs/usr/lib/os-release"
require_file "branding/rootfs/etc/lsb-release"
require_file "branding/rootfs/etc/casper.conf"
require_file "branding/rootfs/etc/issue"
require_file "branding/rootfs/etc/issue.net"
require_file "branding/rootfs/etc/motd"
require_file "branding/rootfs/etc/hostname"
require_file "branding/rootfs/etc/lightdm/slick-greeter.conf.d/99-arcanus.conf"
require_file "branding/rootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
require_file "branding/rootfs/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
contains "branding/rootfs/etc/os-release" "Arcanus OS"
contains "branding/rootfs/etc/issue" "Arcanus OS Alpha"
contains "branding/rootfs/etc/motd" "ARCANUS OS"
echo

echo "Theme and applications"
echo "----------------------"
require_file "theme/Arcanus-Dark/index.theme"
require_file "theme/Arcanus-Dark/gtk-3.0/gtk.css"
require_file "control-centre/arcanus-control-centre"
require_file "control-centre/arcanus-welcome"
require_file "branding/rootfs/usr/share/applications/arcanus-control-centre.desktop"
require_file "branding/rootfs/etc/skel/.config/autostart/arcanus-welcome.desktop"
echo

echo "Scripts"
echo "-------"
require_file "scripts/apply-branding.sh"
require_file "build/build-iso.sh"
require_file "scripts/package-artifact.sh"
[[ -x "$PROJECT_ROOT/scripts/apply-branding.sh" ]] && pass "apply-branding.sh executable" || warn "apply-branding.sh is not executable"
[[ -x "$PROJECT_ROOT/build/build-iso.sh" ]] && pass "build-iso.sh executable" || warn "build-iso.sh is not executable"
[[ -x "$PROJECT_ROOT/scripts/verify-setup.sh" ]] && pass "verify-setup.sh executable" || warn "verify-setup.sh is not executable"
echo

echo "Scope guard"
echo "-----------"
if rg -n "AV Vault|av-vault|X96Q|Armbian" "$PROJECT_ROOT" \
  -g '!dist/**' \
  -g '!.git/**' \
  -g '!scripts/verify-setup.sh' \
  -g '!*.png' \
  -g '!*.jpg' \
  -g '!*.DS_Store' >/tmp/arcanus-scope-hits.txt; then
  warn "legacy Vault/Armbian terms still exist"
  sed -n '1,40p' /tmp/arcanus-scope-hits.txt
else
  pass "no legacy Vault/Armbian terms found in active text files"
fi
echo

if [[ "$ERRORS" -gt 0 ]]; then
  echo "Verification failed: $ERRORS error(s), $WARNINGS warning(s)"
  exit 1
fi

echo "Verification passed: $WARNINGS warning(s)"
