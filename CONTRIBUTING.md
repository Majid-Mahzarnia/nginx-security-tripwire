# Contributing

Contributions are welcome.

Before submitting a pull request:

```bash
bash -n install.sh
bash -n uninstall.sh
bash -n bin/update-attackers.sh
bash -n bin/update-security-web.sh
```

Validate generated Nginx configuration with:

```bash
nginx -t
```

Do not include:

- production IP addresses
- real domains unless they are documentation examples
- passwords
- session cookies
- TLS private keys
- real logs
- internal infrastructure details
