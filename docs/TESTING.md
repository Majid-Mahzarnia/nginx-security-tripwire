# Testing

## Syntax

```bash
nginx -t
```

## Normal request

```bash
curl -kI https://example.com/
```

## Scanner UA

```bash
curl -kI -A 'BurpSuite Professional' https://example.com/
```

Expected:

```text
403
```

## Scanner URI

```bash
curl -kI https://example.com/phpmyadmin
```

Expected:

```text
403
```

## Canary + quarantine

```bash
COOKIE="$(mktemp)"

curl -ksS -c "$COOKIE" -b "$COOKIE" \
-D - -o /dev/null \
https://example.com/__GENERATED_CANARY__

curl -ksSI -b "$COOKIE" https://example.com/

rm -f "$COOKIE"
```

Expected:

```text
Canary request -> 403 + Set-Cookie
Second request -> 403
```

## Candidate log

```bash
tail -20 /opt/nginx-security-tripwire/example.com/data/candidates.log
```

## Dashboard

```bash
curl -kI https://example.com/security/
```

Expected:

```text
200
```

## Fresh browser

A request without the quarantine cookie must still reach the normal application.
