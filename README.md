# Security Dashboard Reset Utility

A reusable Bash utility for resetting a custom web-security dashboard while
preserving monitoring rules and creating a backup first.

## Features

- Timestamped backup before reset
- Clears only `candidates.log`
- Keeps monitoring/security configuration intact
- Rebuilds attacker data
- Regenerates the dashboard
- Pre-flight safety checks

## Expected structure

```text
/opt/web-security/
├── bin/
│   ├── reset-security-dashboard.sh
│   ├── update-example-attackers.sh
│   └── update-example-security-web.sh
├── data/
│   └── example.com/
│       └── candidates.log
└── backup/
```

## Configure

Edit:

```bash
SITE="example.com"
PREFIX="example"
```

## Install

```bash
sudo cp reset-security-dashboard.sh /opt/web-security/bin/
sudo chown root:root /opt/web-security/bin/reset-security-dashboard.sh
sudo chmod 700 /opt/web-security/bin/reset-security-dashboard.sh
```

## Run

```bash
sudo /opt/web-security/bin/reset-security-dashboard.sh
```

## Security

Do not commit production IP addresses, domains, credentials, firewall
configuration, or real security-event logs to a public repository.

## License

MIT
