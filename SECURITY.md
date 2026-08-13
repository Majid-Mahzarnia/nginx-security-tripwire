# Security Policy

## Reporting a vulnerability

Please do not publish exploitable security issues as a public GitHub issue.

Use a private security advisory or contact the project maintainer directly.

Please include:

- affected version
- Nginx version
- operating system
- relevant configuration
- reproduction steps
- expected result
- actual result
- impact assessment

## Security assumptions

This project assumes:

- Nginx configuration is managed by a trusted administrator.
- The host itself is not compromised.
- TLS private keys remain protected.
- Application-level authentication and authorization are implemented separately.
- Candidate logs may contain client IP addresses and should be protected appropriately.
