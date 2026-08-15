#!/usr/bin/env bash
#
# nginx-security-tripwire - Security Dashboard Reset Utility
#
# Safely resets dashboard event history while preserving the Tripwire
# configuration. A timestamped backup is created before any data is cleared.
#
# Configure SITE and PREFIX for the installed instance before use.
#
set -euo pipefail

BASE="${BASE:-/opt/web-security}"
SITE="${SITE:-example.com}"
PREFIX="${PREFIX:-example}"

DATA="$BASE/data/$SITE"
LOG="$DATA/candidates.log"
BACKUP_ROOT="$BASE/backup/$SITE"

UPDATE_ATTACKERS="$BASE/bin/update-${PREFIX}-attackers.sh"
UPDATE_WEB="$BASE/bin/update-${PREFIX}-security-web.sh"

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BACKUP_ROOT/dashboard-reset-$STAMP"

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

echo "============================================================"
echo " nginx-security-tripwire - Dashboard Reset"
echo "============================================================"
echo "Site : $SITE"
echo "Data : $DATA"
echo

[[ "$(id -u)" -eq 0 ]] || die "This script must be run as root."
[[ -d "$DATA" ]] || die "Missing data directory: $DATA"
[[ -f "$LOG" ]] || die "Missing event log: $LOG"
[[ -x "$UPDATE_ATTACKERS" ]] || die "Missing/not executable: $UPDATE_ATTACKERS"
[[ -x "$UPDATE_WEB" ]] || die "Missing/not executable: $UPDATE_WEB"

CURRENT_COUNT="$(wc -l < "$LOG")"

echo "[1/4] Creating timestamped backup..."
mkdir -p "$BACKUP"
cp -a "$DATA/." "$BACKUP/"
echo "[OK] Backup: $BACKUP"

echo
echo "[2/4] Clearing dashboard event history..."
: > "$LOG"
echo "[OK] candidates.log cleared"

echo
echo "[3/4] Rebuilding attacker data..."
"$UPDATE_ATTACKERS"

echo
echo "[4/4] Rebuilding security dashboard..."
"$UPDATE_WEB"

NEW_COUNT="$(wc -l < "$LOG")"

echo
echo "============================================================"
echo " Reset completed successfully"
echo "============================================================"
echo "Previous events : $CURRENT_COUNT"
echo "Current events  : $NEW_COUNT"
echo "Backup          : $BACKUP"
echo
echo "Tripwire monitoring remains enabled; new events will continue to be recorded."
