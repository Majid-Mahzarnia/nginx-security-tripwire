# Configuration

## Detection policy

High-confidence events:

```text
CANARY
IMPOSSIBLE_URI
```

Default behavior:

```text
candidate log + quarantine cookie + fixed 403
```

Lower-confidence scanner events:

```text
SCANNER_URI
SCANNER_UA
CRAWLER_UA
```

Default behavior:

```text
candidate log + fixed 403
```

No quarantine by default.

## Quarantine levels

Default template:

```text
Level 1: 60 seconds
Level 2: 300 seconds
Level 3: 1800 seconds
Level 4: 7200 seconds
```

The default pre-gate blocks a quarantined browser immediately, so automatic escalation requires additional policy changes.

## Dashboard

Default:

```text
/security/
```

## Candidate endpoint

Randomized during installation:

```text
/__security_candidates_<random>
```

Protect or disable this endpoint if IP addresses must not be publicly visible.

## Scanner rules

The project expects these global variables:

```text
$bad_bot
$crawler_bot
$scanner_uri
```

Use `templates/global-maps.conf.template` if your Nginx configuration does not already define them.
