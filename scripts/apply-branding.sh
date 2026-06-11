#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <mounted-rootfs>" >&2
  exit 2
fi

ROOTFS="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OVERLAY="$REPO_ROOT/branding/rootfs"

if [[ ! -d "$ROOTFS/etc" ]]; then
  echo "Rootfs path does not look valid: $ROOTFS" >&2
  exit 1
fi

while IFS= read -r -d '' dir; do
  rel="${dir#$OVERLAY}"
  install -d "$ROOTFS/$rel"
done < <(find "$OVERLAY" -type d -print0)

while IFS= read -r -d '' file; do
  rel="${file#$OVERLAY/}"
  target="$ROOTFS/$rel"
  install -d "$(dirname "$target")"
  install -m 0644 "$file" "$target"
done < <(find "$OVERLAY" -type f ! -name ".DS_Store" -print0)

install -d "$ROOTFS/usr/local/bin"
install -m 0755 "$REPO_ROOT/scripts/av-vault-launcher" "$ROOTFS/usr/local/bin/av-vault-launcher"

echo "Applied Arcanus Vault OS branding to $ROOTFS"
