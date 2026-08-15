#!/usr/bin/env bash
set -euo pipefail

BASE="/opt/web-security"
SITE="example.com"
PREFIX="example"

DATA="$BASE/data/$SITE"
LOG="$DATA/candidates.log"
BACKUP_ROOT="$BASE/backup/$SITE"
UPDATE_ATTACKERS="$BASE/bin/update-${PREFIX}-attackers.sh"
UPDATE_WEB="$BASE/bin/update-${PREFIX}-security-web.sh"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BACKUP_ROOT/dashboard-reset-$STAMP"

die() { echo "[ERROR] $*" >&2; exit 1; }

echo "=== Security Dashboard Reset: $SITE ==="

[[ "$(id -u)" -eq 0 ]] || die "Run as root."
[[ -d "$DATA" ]] || die "Missing: $DATA"
[[ -f "$LOG" ]] || die "Missing: $LOG"
[[ -x "$UPDATE_ATTACKERS" ]] || die "Missing/not executable: $UPDATE_ATTACKERS"
[[ -x "$UPDATE_WEB" ]] || die "Missing/not executable: $UPDATE_WEB"

CURRENT_COUNT="$(wc -l < "$LOG")"

mkdir -p "$BACKUP"
cp -a "$DATA/." "$BACKUP/"

: > "$LOG"

"$UPDATE_ATTACKERS"
"$UPDATE_WEB"

NEW_COUNT="$(wc -l < "$LOG")"

echo "Previous events : $CURRENT_COUNT"
echo "Current events  : $NEW_COUNT"
echo "Backup          : $BACKUP"
echo "Done. New security events will continue to be recorded."
