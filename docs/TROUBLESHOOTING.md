# Troubleshooting

## `nginx -t` fails

Do not reload Nginx.

Restore the vhost backup created by the installer and remove the generated `conf.d` file.

## Candidate endpoint returns 403

Check filesystem permissions:

```bash
namei -l /opt/nginx-security-tripwire/example.com/data/candidates.log
```

The Nginx worker needs directory traverse permission and file read permission.

## Scanner response differs from canary response

Ensure all security handlers include the same canonical reject response.

## Canary logs but browser is not quarantined

Check:

```bash
grep -n 'quarantine' /etc/nginx/conf.d/security-tripwire-*.conf
```

and verify the tripwire handler sets the quarantine cookie.

## Dashboard does not update

Check:

```bash
systemctl status cron
cat /etc/cron.d/security-tripwire-*
```

Then manually run the update scripts.

## Existing application breaks

Immediately restore the vhost backup and reload only after `nginx -t` succeeds.
