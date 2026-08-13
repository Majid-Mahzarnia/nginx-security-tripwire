# Release Checklist

Before publishing:

- [ ] No production domains remain
- [ ] No production IP addresses remain
- [ ] No session IDs remain
- [ ] No passwords or secrets remain
- [ ] No TLS private keys remain
- [ ] No real candidate logs remain
- [ ] No firewall configuration remains
- [ ] No production canary URLs remain
- [ ] `bash -n` passes for every shell script
- [ ] Installer tested on a disposable Nginx vhost
- [ ] Uninstaller tested on the same disposable vhost
- [ ] `nginx -t` passes after install
- [ ] `nginx -t` passes after uninstall
- [ ] Normal application still works
- [ ] Scanner UA returns deterministic 403
- [ ] Scanner URI returns deterministic 403
- [ ] Canary sets quarantine cookie
- [ ] Same browser is blocked after canary
- [ ] Fresh browser remains normal
- [ ] Dashboard works
- [ ] Candidate endpoint works or is intentionally disabled
- [ ] Cron works
