#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || {
    echo "ERROR: run as root"
    exit 1
}

ROOT="/opt/nginx-security-tripwire"
NGINX_CONF_D="/etc/nginx/conf.d"
CRON_DIR="/etc/cron.d"

echo "============================================================"
echo " NGINX SECURITY TRIPWIRE INSTALLER"
echo "============================================================"

read -r -p "Domain (example.com): " SITE
read -r -p "Full Nginx vhost path: " VHOST

[[ -n "$SITE" ]] || { echo "ERROR: empty domain"; exit 1; }
[[ -f "$VHOST" ]] || { echo "ERROR: vhost not found: $VHOST"; exit 1; }

NS="$(printf '%s' "$SITE" | tr '.-' '__' | tr -cd '[:alnum:]_')"
COOKIE_NAME="${NS}_quarantine"
RAND="$(openssl rand -hex 4)"
CANARY_1="__security_sysdiag_${RAND}"
CANARY_2="__security_backup_$(openssl rand -hex 4)"
CANARY_3="__security_debug_$(openssl rand -hex 4)"
CANARY_4="__security_admin_api_$(openssl rand -hex 4)"
CANDIDATE_ENDPOINT="__security_candidates_$(openssl rand -hex 4)"

SITE_DIR="$ROOT/$SITE"
CONFIG_DIR="$SITE_DIR/config"
DATA_DIR="$SITE_DIR/data"
WEB_DIR="$SITE_DIR/web"
BACKUP_DIR="$SITE_DIR/backup"

TRIPWIRE_FILE="$NGINX_CONF_D/security-tripwire-${NS}.conf"
REJECT_FILE="$CONFIG_DIR/reject-response.conf"
INTEGRATION_FILE="$CONFIG_DIR/integration.conf"
CANDIDATES_FILE="$DATA_DIR/candidates.log"
ATTACKERS_FILE="$DATA_DIR/attackers.txt"
DASHBOARD_FILE="$WEB_DIR/index.html"
SECURITY_HEADERS="$CONFIG_DIR/security-headers.conf"
CRON_FILE="$CRON_DIR/security-tripwire-${NS}"

MARKER="# NGINX-SECURITY-TRIPWIRE-INSTALL-HERE"

echo
echo "===== PRECHECK ====="
nginx -t

grep -Fq "$MARKER" "$VHOST" || {
    echo
    echo "ERROR: installation marker not found in HTTPS server block:"
    echo
    echo "    $MARKER"
    echo
    echo "Add that line at the exact location where the integration block should be inserted."
    echo "No vhost change was made."
    exit 1
}

if [[ -e "$TRIPWIRE_FILE" ]]; then
    echo "ERROR: tripwire file already exists: $TRIPWIRE_FILE"
    exit 1
fi

install -d -o root -g root -m 750 "$CONFIG_DIR" "$DATA_DIR"
install -d -o root -g root -m 755 "$WEB_DIR"
install -d -o root -g root -m 700 "$BACKUP_DIR"

BACKUP="$BACKUP_DIR/$(basename "$VHOST").$(date +%Y%m%d-%H%M%S).bak"
cp -a "$VHOST" "$BACKUP"

echo "Backup: $BACKUP"

cp templates/reject-response.conf "$REJECT_FILE"
cp templates/security-headers.conf "$SECURITY_HEADERS"

sed \
    -e "s/__NS__/${NS}/g" \
    -e "s/__CANARY_1__/${CANARY_1}/g" \
    -e "s/__CANARY_2__/${CANARY_2}/g" \
    -e "s/__CANARY_3__/${CANARY_3}/g" \
    -e "s/__CANARY_4__/${CANARY_4}/g" \
    -e "s/__COOKIE_NAME__/${COOKIE_NAME}/g" \
    -e "s/__CANDIDATE_ENDPOINT__/${CANDIDATE_ENDPOINT}/g" \
    templates/tripwire.conf.template > "$TRIPWIRE_FILE"

sed \
    -e "s/__NS__/${NS}/g" \
    -e "s#__REJECT_FILE__#${REJECT_FILE}#g" \
    -e "s#__CANDIDATES_FILE__#${CANDIDATES_FILE}#g" \
    -e "s#__WEB_ROOT__#${WEB_DIR}#g" \
    -e "s#__SECURITY_HEADERS__#${SECURITY_HEADERS}#g" \
    -e "s/__COOKIE_NAME__/${COOKIE_NAME}/g" \
    -e "s/__CANDIDATE_ENDPOINT__/${CANDIDATE_ENDPOINT}/g" \
    templates/integration.conf.template > "$INTEGRATION_FILE"

touch "$CANDIDATES_FILE" "$ATTACKERS_FILE"
chmod 640 "$CANDIDATES_FILE" "$ATTACKERS_FILE"

# Let nginx workers traverse/read candidate log without changing ownership.
if command -v setfacl >/dev/null 2>&1; then
    setfacl -m u:www-data:x "$ROOT" 2>/dev/null || true
    setfacl -m u:www-data:x "$SITE_DIR" 2>/dev/null || true
    setfacl -m u:www-data:rx "$DATA_DIR" 2>/dev/null || true
    setfacl -m u:www-data:r "$CANDIDATES_FILE" 2>/dev/null || true
fi

python3 - "$VHOST" "$MARKER" "$INTEGRATION_FILE" <<'PY'
import sys
from pathlib import Path

vhost = Path(sys.argv[1])
marker = sys.argv[2]
integration = Path(sys.argv[3]).read_text()

text = vhost.read_text()
if text.count(marker) != 1:
    print("ERROR: marker must occur exactly once")
    sys.exit(1)

text = text.replace(marker, marker + "\n\n" + integration, 1)
vhost.write_text(text)
PY

# Build initial dashboard
bin/update-attackers.sh "$CANDIDATES_FILE" "$ATTACKERS_FILE"
bin/update-security-web.sh "$SITE" "$CANDIDATES_FILE" "$ATTACKERS_FILE" "$DASHBOARD_FILE"

cat > "$CRON_FILE" <<CRON
# Nginx Security Tripwire - $SITE
* * * * * root $ROOT/current/bin/update-attackers.sh "$CANDIDATES_FILE" "$ATTACKERS_FILE" && $ROOT/current/bin/update-security-web.sh "$SITE" "$CANDIDATES_FILE" "$ATTACKERS_FILE" "$DASHBOARD_FILE" >> "$SITE_DIR/cron.log" 2>&1
CRON

chmod 644 "$CRON_FILE"

# Persist install metadata
cat > "$SITE_DIR/install.env" <<ENV
SITE='$SITE'
VHOST='$VHOST'
NS='$NS'
COOKIE_NAME='$COOKIE_NAME'
TRIPWIRE_FILE='$TRIPWIRE_FILE'
REJECT_FILE='$REJECT_FILE'
INTEGRATION_FILE='$INTEGRATION_FILE'
CANDIDATES_FILE='$CANDIDATES_FILE'
ATTACKERS_FILE='$ATTACKERS_FILE'
DASHBOARD_FILE='$DASHBOARD_FILE'
SECURITY_HEADERS='$SECURITY_HEADERS'
CRON_FILE='$CRON_FILE'
BACKUP='$BACKUP'
CANDIDATE_ENDPOINT='$CANDIDATE_ENDPOINT'
CANARY_1='$CANARY_1'
CANARY_2='$CANARY_2'
CANARY_3='$CANARY_3'
CANARY_4='$CANARY_4'
ENV
chmod 600 "$SITE_DIR/install.env"

echo
echo "===== NGINX TEST ====="
if ! nginx -t; then
    echo "ERROR: generated Nginx config is invalid."
    echo "Restoring vhost backup..."
    cp -a "$BACKUP" "$VHOST"
    rm -f "$TRIPWIRE_FILE" "$CRON_FILE"
    nginx -t || true
    exit 1
fi

echo
echo "INSTALLATION PREPARED SUCCESSFULLY"
echo
echo "Domain: $SITE"
echo "Canaries:"
echo "  https://${SITE}/${CANARY_1}"
echo "  https://${SITE}/${CANARY_2}"
echo "  https://${SITE}/${CANARY_3}"
echo "  https://${SITE}/${CANARY_4}"
echo
echo "Dashboard:"
echo "  https://${SITE}/security/"
echo
echo "Candidate log:"
echo "  https://${SITE}/${CANDIDATE_ENDPOINT}"
echo
echo "Quarantine cookie:"
echo "  $COOKIE_NAME"
echo
echo "Nginx has NOT been reloaded."
echo
echo "To activate:"
echo "  nginx -t && systemctl reload nginx"
