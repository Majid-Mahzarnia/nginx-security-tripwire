# Changelog

## 1.1.2 - 2026-08-15

- Added `bin/reset-security-dashboard.sh`.
- Added safe timestamped backup before dashboard-history reset.
- Rebuilds attacker data and dashboard after reset.
- Preserves the existing project structure and configuration.

## [1.1.1] - 2026-08-13

### Fixed

- Fixed XML escaping in SVG diagram titles so GitHub can render embedded diagrams correctly.


## [1.1.0] - 2026-08-13

### Added

- Visual architecture documentation
- Detection flow diagram
- Detection policy matrix
- File dependency map
- Installation flow diagram
- Uninstall / rollback flow diagram

## [1.0.0] - 2026-08-13

### Added

- Canary URL detection
- Impossible URI detection
- Scanner URI detection
- Scanner User-Agent detection
- Optional crawler detection
- Deterministic security rejection response
- Candidate event logging
- Attacker aggregation
- Cookie-based quarantine
- Security dashboard
- Cron-based dashboard refresh
- Automatic installation helper
- Automatic uninstall helper
- Manual installation documentation
- Manual removal documentation