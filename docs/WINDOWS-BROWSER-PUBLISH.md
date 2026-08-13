# Publishing to GitHub from Windows using only a browser

## 1. Create the repository

In GitHub:

```text
+ -> New repository
```

Recommended:

```text
Repository name: nginx-security-tripwire
Visibility: Public
```

Do not ask GitHub to create a README, `.gitignore`, or license because the package already contains them.

## 2. Upload the project files

Open the new repository.

Select:

```text
Add file -> Upload files
```

Drag the extracted project files and directories into the browser.

Commit message:

```text
Initial public release
```

Commit directly to `main`.

## 3. Verify the repository

Confirm that these files are visible:

```text
README.md
LICENSE
SECURITY.md
CHANGELOG.md
CONTRIBUTING.md
install.sh
uninstall.sh
bootstrap.sh
bin/
templates/
docs/
examples/
```

Confirm that the images render in README:

```text
docs/images/architecture.svg
docs/images/detection-flow.svg
docs/images/policy-matrix.svg
docs/images/dependency-map.svg
docs/images/install-flow.svg
docs/images/uninstall-flow.svg
```

## 4. Create a release

Go to:

```text
Releases -> Draft a new release
```

Use:

```text
Tag: v1.1.0
Release title: Nginx Security Tripwire v1.1.0
```

Attach:

```text
nginx-security-tripwire-public-v1.1.0.zip
nginx-security-tripwire-public-v1.1.0.zip.sha256
```

## 5. Suggested repository description

```text
Lightweight defensive security layer for Nginx with canary detection, scanner blocking, candidate logging, browser quarantine and a security dashboard.
```

## 6. Suggested topics

```text
nginx
security
cybersecurity
tripwire
honeypot
canary
waf
web-security
blue-team
linux
devsecops
```
