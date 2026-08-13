#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?Usage: update-security-web.sh SITE CANDIDATES ATTACKERS OUTPUT}"
SOURCE="${2:?}"
ATTACKERS="${3:?}"
OUTPUT="${4:?}"
TMP="${OUTPUT}.tmp"

TOTAL_EVENTS=0
UNIQUE_IPS=0

[[ -f "$SOURCE" ]] && TOTAL_EVENTS="$(wc -l < "$SOURCE" | tr -d ' ')"
[[ -s "$ATTACKERS" ]] && UNIQUE_IPS="$(wc -l < "$ATTACKERS" | tr -d ' ')"

UPDATED="$(date '+%Y-%m-%d %H:%M:%S %z')"

{
cat <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>Security Dashboard - ${SITE}</title>
<style>
body{margin:0;padding:30px;font-family:Arial,sans-serif;background:#f5f5f5;color:#222}
.container{max-width:1200px;margin:auto}
.cards{display:flex;gap:15px;flex-wrap:wrap;margin:20px 0}
.card{background:#fff;border:1px solid #ddd;padding:20px;min-width:200px;border-radius:8px}
.number{font-size:30px;font-weight:bold}
table{width:100%;border-collapse:collapse;background:#fff}
th,td{border:1px solid #ddd;padding:10px;text-align:left;vertical-align:top}
th{background:#eee}
pre{white-space:pre-wrap;word-break:break-word}
.log{margin-top:25px;background:#fff;border:1px solid #ddd;padding:15px}
</style>
</head>
<body>
<div class="container">
<h1>Security Dashboard</h1>
<p>${SITE}</p>
<div class="cards">
<div class="card"><div>Events</div><div class="number">${TOTAL_EVENTS}</div></div>
<div class="card"><div>Unique IPs</div><div class="number">${UNIQUE_IPS}</div></div>
</div>
<h2>Detected IPs</h2>
<table>
<thead><tr><th>IP</th><th>Events</th><th>Last reason</th><th>Last URI</th></tr></thead>
<tbody>
HTML

if [[ -s "$ATTACKERS" ]]; then
    while read -r IP COUNT; do
        [[ -n "${IP:-}" ]] || continue

        LAST_LINE="$(
            awk -F'|' -v ip="$IP" '
            {
                x=$2
                gsub(/^[ \t]+|[ \t]+$/, "", x)
                if (x == ip) last=$0
            }
            END { if (last != "") print last }
            ' "$SOURCE"
        )"

        REASON="$(printf '%s\n' "$LAST_LINE" | awk -F'|' '{x=$3; gsub(/^[ \t]+|[ \t]+$/, "", x); print x}')"
        URI="$(printf '%s\n' "$LAST_LINE" | awk -F'|' '{x=$4; gsub(/^[ \t]+|[ \t]+$/, "", x); print x}')"

        printf '<tr><td><code>%s</code></td><td>%s</td><td>%s</td><td><code>%s</code></td></tr>\n' \
            "$IP" "$COUNT" "$REASON" "$URI"
    done < "$ATTACKERS"
else
    echo '<tr><td colspan="4">No security events recorded yet.</td></tr>'
fi

cat <<HTML
</tbody>
</table>
<h2>Recent events</h2>
<div class="log"><pre>
HTML

if [[ -s "$SOURCE" ]]; then
    tail -50 "$SOURCE"
else
    echo "No security events recorded yet."
fi

cat <<HTML
</pre></div>
<p>Last update: ${UPDATED}</p>
</div>
</body>
</html>
HTML
} > "$TMP"

chmod 644 "$TMP"
mv "$TMP" "$OUTPUT"
