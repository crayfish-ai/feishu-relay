# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 3.x     | :white_check_mark: |
| < 3.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within feishu-relay, please report it responsibly.

**Please do NOT open a public GitHub issue** for security vulnerabilities.

Instead, please report it by one of the following methods:

- **Private vulnerability reporting**: Use GitHub's [Private vulnerability reporting](https://github.com/crayfish-ai/feishu-relay/security/advisories/new) (preferred)
- **Email**: Contact the maintainer directly via GitHub

When reporting, please include:

1. A description of the vulnerability
2. Steps to reproduce the issue
3. Potential impact of the vulnerability
4. Any suggested fixes (optional)

## Disclosure Policy

We follow a responsible disclosure model:

1. Reporter submits vulnerability privately
2. We acknowledge receipt within 48 hours
3. We work on a fix with the reporter (via private channel)
4. Once fixed, we publish a security advisory and credit the reporter (with permission)

## Security Best Practices (For Users)

When deploying feishu-relay:

- **Never commit credentials** to the repository
- Use environment variables or a secrets manager for API keys
- Rotate Feishu App credentials regularly
- Limit the permissions of the Feishu app to the minimum required
- Review and rotate the `FEISHU_APP_SECRET` if the repository has been exposed

## Credentials and Secrets

This skill requires the following sensitive values:

| Variable | Description | Risk |
|----------|-------------|------|
| `FEISHU_APP_ID` | Feishu application ID | Medium - identifies your app |
| `FEISHU_APP_SECRET` | Feishu application secret | High - grants API access |

**Never** commit these values to the repository. Use `.env` files (gitignored) or environment variables instead.
