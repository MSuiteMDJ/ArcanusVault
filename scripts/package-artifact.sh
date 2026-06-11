#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <image.img.xz>" >&2
  exit 2
fi

SOURCE="$1"
TARGET_DIR="dist"
TARGET="$TARGET_DIR/AVVaultOS-X96Q-Prototype-0.1.img.xz"

if [[ ! -f "$SOURCE" ]]; then
  echo "Image not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE" "$TARGET"
echo "$TARGET"
