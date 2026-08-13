# Manual Installation

## 1. Verify the existing site

```bash
nginx -t
```

Identify the HTTPS virtual host:

```bash
nginx -T | less
```

## 2. Choose a namespace

Example:

```text
example_com
```

All generated variables must use that namespace.

## 3. Create directories

```bash
mkdir -p /opt/nginx-security-tripwire/example.com/{config,data,web,backup}
chmod 750 /opt/nginx-security-tripwire/example.com/config
chmod 750 /opt/nginx-security-tripwire/example.com/data
chmod 755 /opt/nginx-security-tripwire/example.com/web
chmod 700 /opt/nginx-security-tripwire/example.com/backup
```

## 4. Generate random canaries

```bash
openssl rand -hex 4
```

Create four unique values.

## 5. Create the tripwire map file

Copy:

```text
templates/tripwire.conf.template
```

Replace:

```text
__NS__
__CANARY_1__
__CANARY_2__
__CANARY_3__
__CANARY_4__
__COOKIE_NAME__
__CANDIDATE_ENDPOINT__
```

Install as:

```text
/etc/nginx/conf.d/security-tripwire-example_com.conf
```

## 6. Create the reject response

Copy:

```text
templates/reject-response.conf
```

to:

```text
/opt/nginx-security-tripwire/example.com/config/reject-response.conf
```

## 7. Create data files

```bash
touch /opt/nginx-security-tripwire/example.com/data/candidates.log
touch /opt/nginx-security-tripwire/example.com/data/attackers.txt
chmod 640 /opt/nginx-security-tripwire/example.com/data/*
```

If Nginx must serve the candidate log, give the Nginx worker read/traverse access using ACL or an appropriate group.

Example:

```bash
setfacl -m u:www-data:x /opt/nginx-security-tripwire
setfacl -m u:www-data:x /opt/nginx-security-tripwire/example.com
setfacl -m u:www-data:rx /opt/nginx-security-tripwire/example.com/data
setfacl -m u:www-data:r /opt/nginx-security-tripwire/example.com/data/candidates.log
```

## 8. Integrate into the HTTPS server block

Copy the generated integration block into the HTTPS `server {}` block.

Recommended order:

```text
Host validation
Security quarantine pre-gate
Security detection pre-gate
Existing maintenance logic
Existing scanner rules
Existing error pages
Security handlers / logging / dashboard
Rate limiting
Static/application/PHP routes
```

Do not delete existing application routes.

## 9. Validate

```bash
nginx -t
```

## 10. Reload

```bash
systemctl reload nginx
```

## 11. Test

Normal request:

```bash
curl -kI https://example.com/
```

Scanner UA:

```bash
curl -kI -A 'BurpSuite Professional' https://example.com/
```

Scanner URI:

```bash
curl -kI https://example.com/phpmyadmin
```

Canary:

```bash
curl -kc /tmp/cookie -b /tmp/cookie \
https://example.com/__GENERATED_CANARY__
```

Then:

```bash
curl -kb /tmp/cookie -I https://example.com/
```

Expected:

```text
Canary -> 403 + quarantine cookie
Subsequent request with same cookie -> 403
Fresh client -> normal application
```
