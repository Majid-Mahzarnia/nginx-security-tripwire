#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:?Usage: update-attackers.sh CANDIDATES_FILE ATTACKERS_FILE}"
DEST="${2:?Usage: update-attackers.sh CANDIDATES_FILE ATTACKERS_FILE}"
TMP="${DEST}.tmp"

test -f "$SOURCE" || {
    echo "ERROR: candidate source missing: $SOURCE" >&2
    exit 1
}

awk -F'|' '
{
    ip=$2
    gsub(/^[ \t]+|[ \t]+$/, "", ip)

    if (ip != "") {
        count[ip]++
    }
}
END {
    for (ip in count) {
        print ip, count[ip]
    }
}
' "$SOURCE" | sort -k2,2nr -k1,1 > "$TMP"

chmod 640 "$TMP"
mv "$TMP" "$DEST"
