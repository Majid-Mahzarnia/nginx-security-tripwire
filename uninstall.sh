#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || {
    echo "ERROR: run as root"
    exit 1
}

ROOT="/opt/nginx-security-tripwire"

read -r -p "Domain to uninstall: " SITE
SITE_DIR="$ROOT/$SITE"
META="$SITE_DIR/install.env"

[[ -f "$META" ]] || {
    echo "ERROR: installation metadata not found: $META"
    exit 1
}

# shellcheck disable=SC1090
source "$META"

echo "============================================================"
echo " NGINX SECURITY TRIPWIRE UNINSTALLER"
echo "============================================================"

echo "Domain : $SITE"
echo "Vhost  : $VHOST"

nginx -t

UNINSTALL_BACKUP="$SITE_DIR/backup/pre-uninstall-$(date +%Y%m%d-%H%M%S).conf"
cp -a "$VHOST" "$UNINSTALL_BACKUP"

python3 - "$VHOST" <<'PY'
import re, sys
from pathlib import Path

p = Path(sys.argv[1])
text = p.read_text()

pattern = re.compile(
    r'\n?# NGINX-SECURITY-TRIPWIRE-BEGIN.*?# NGINX-SECURITY-TRIPWIRE-END\n?',
    re.S
)

new, count = pattern.subn("\n", text)

if count != 1:
    print(f"ERROR: expected exactly one managed block, found {count}")
    sys.exit(1)

p.write_text(new)
PY

rm -f "$TRIPWIRE_FILE"
rm -f "$CRON_FILE"

if ! nginx -t; then
    echo "ERROR: nginx -t failed after removal."
    echo "Restoring vhost..."
    cp -a "$UNINSTALL_BACKUP" "$VHOST"
    nginx -t || true
    exit 1
fi

echo
read -r -p "Delete security logs/data/dashboard for $SITE? [y/N]: " DELETE_DATA

if [[ "$DELETE_DATA" =~ ^[Yy]$ ]]; then
    rm -rf "$SITE_DIR"
    echo "Security data removed."
else
    echo "Security data kept at: $SITE_DIR"
fi

echo
echo "Uninstall completed."
echo "Nginx has NOT been reloaded."
echo
echo "To activate removal:"
echo "  nginx -t && systemctl reload nginx"
