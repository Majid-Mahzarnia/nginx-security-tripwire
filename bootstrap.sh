#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "ERROR: run as root"; exit 1; }

DEST="/opt/nginx-security-tripwire/current"
mkdir -p /opt/nginx-security-tripwire
rm -rf "$DEST"
cp -a "$(cd "$(dirname "$0")" && pwd)" "$DEST"

echo "Installed repository runtime files to:"
echo "$DEST"
echo
echo "Now run:"
echo "cd $DEST && ./install.sh"
