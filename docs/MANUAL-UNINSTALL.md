# Manual Uninstall

## 1. Identify project files

Example:

```text
/etc/nginx/conf.d/security-tripwire-example_com.conf
/opt/nginx-security-tripwire/example.com/
/etc/cron.d/security-tripwire-example_com
```

## 2. Back up the active vhost

```bash
cp -a /etc/nginx/sites-available/example.com \
/root/example.com.before-tripwire-removal.conf
```

## 3. Remove the managed vhost block

Remove only the content between:

```text
# NGINX-SECURITY-TRIPWIRE-BEGIN
# NGINX-SECURITY-TRIPWIRE-END
```

Do not remove unrelated Nginx configuration.

## 4. Remove the tripwire map file

```bash
rm /etc/nginx/conf.d/security-tripwire-example_com.conf
```

## 5. Remove cron

```bash
rm /etc/cron.d/security-tripwire-example_com
```

## 6. Validate Nginx

```bash
nginx -t
```

If validation fails, restore the vhost backup immediately.

## 7. Reload

```bash
systemctl reload nginx
```

## 8. Optional data removal

Only after successful Nginx validation:

```bash
rm -rf /opt/nginx-security-tripwire/example.com
```

Keep logs if they are required for incident history.
