# Security Considerations

## Permission Boundaries

### What This Skill Can Do

| Capability | Required Permission | Scope |
|------------|---------------------|-------|
| Send messages | Feishu API token | Feishu only |
| Read config | File system read | Skill directory |
| Write logs | File system write | Logs directory |

### What This Skill Cannot Do

- ❌ Cannot access files outside skill directory (without explicit path)
- ❌ Cannot modify system files (without root)
- ❌ Cannot access other users' data
- ❌ Cannot execute arbitrary code

---

## Credential Storage

### Recommended: Environment Variables

```bash
export FEISHU_APP_ID="cli_xxx"
export FEISHU_APP_SECRET="xxx"
```

**Pros**: No file storage, cleared on logout
**Cons**: Must be set in each session

### Alternative: Skill Config File

```bash
# Create config.json
cat > config.json << 'EOF'
{
  "appId": "cli_xxx",
  "appSecret": "xxx",
  "receiveId": "ou_xxx"
}
EOF

# Protect the file
chmod 600 config.json
```

**Pros**: Persistent, easy to manage
**Cons**: File-based, needs filesystem security

### Not Recommended

- ❌ Committing credentials to git
- ❌ Storing in world-readable locations
- ❌ Using default permissions (644)

---

## Production Installation Risks

### Global Notify Link (`/usr/local/bin/notify`)

| Risk | Mitigation |
|------|------------|
| Overwrites existing `notify` | Backup before install |
| Available to all users | Restrict file permissions |
| Path confusion | Use absolute path in scripts |

### Crontab Integration

| Risk | Mitigation |
|------|------------|
| Duplicate entries | Script checks before adding |
| Syntax errors | Test with `--dry-run` first |
| Permission issues | Install as intended user |

### Systemd Service

| Risk | Mitigation |
|------|------------|
| Persistence across reboots | User-level service (not system) |
| Logs in journal | `journalctl --user -u feishu-notifier` |
| Startup failures | Check status after install |

---

## Best Practices

1. **Use minimal permissions**: Don't run as root unless necessary
2. **Protect config files**: `chmod 600 config.json`
3. **Review before install**: Read install scripts before running
4. **Use `--dry-run`**: Test changes before applying
5. **Monitor logs**: Check for unusual activity
6. **Rotate credentials**: Periodically update appSecret
7. **Backup**: Keep backups of working configurations

---

## Incident Response

If you suspect unauthorized access:

1. **Revoke credentials**: Regenerate appSecret in Feishu console
2. **Check logs**: Look for unusual send patterns
3. **Remove skill**: `./docs/uninstall.sh --complete`
4. **Report**: Contact Feishu if abuse detected

---

## Compliance

This skill is designed to:

- ✅ Not store credentials beyond local config
- ✅ Not transmit data outside Feishu API
- ✅ Not log sensitive information
- ✅ Support GDPR-compliant usage (user controls data)

---

## Questions?

Open an issue at: https://github.com/crayfish-ai/feishu-notifier/issues
