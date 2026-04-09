# Uninstallation Guide

Complete removal of feishu-notifier and all optional components.

---

## Quick Remove (Core Only)

If you only installed the core skill:

```bash
# Remove skill directory
rm -rf ~/.openclaw/skills/feishu-notifier

# Remove config (if any)
rm -f ~/.openclaw/skills/feishu-notifier/config.json

# Remove logs (if any)
rm -rf ~/.openclaw/skills/feishu-notifier/logs
```

---

## Complete Remove (All Capabilities)

### Step 1: Remove Global Notify Link

```bash
# Check if installed
ls -la /usr/local/bin/notify 2>/dev/null

# Remove if exists
sudo rm -f /usr/local/bin/notify

# Or if installed in home directory
rm -f ~/bin/notify
```

### Step 2: Remove Crontab Entries

```bash
# View current crontab
crontab -l | grep feishu

# Remove all feishu entries
crontab -l | grep -v feishu | crontab -

# Or use the uninstaller
./scripts/install-crontab.sh --uninstall
```

### Step 3: Remove Systemd Service

```bash
# Stop service
systemctl --user stop feishu-notifier 2>/dev/null

# Disable service
systemctl --user disable feishu-notifier 2>/dev/null

# Remove service file
rm -f ~/.config/systemd/user/feishu-notifier.service

# Reload systemd
systemctl --user daemon-reload
```

### Step 4: Remove Discovery Links

```bash
./scripts/install-discovery.sh --uninstall
```

### Step 5: Remove Core Skill

```bash
rm -rf ~/.openclaw/skills/feishu-notifier
```

### Step 6: Clean Environment Variables

Remove from `~/.bashrc` or `~/.zshrc`:

```bash
# Find feishu related exports
grep -n "FEISHU_" ~/.bashrc

# Remove them
# Example lines to remove:
# export FEISHU_APP_ID="..."
# export FEISHU_APP_SECRET="..."
# export FEISHU_RECEIVE_ID="..."
# export FEISHU_RECEIVE_ID_TYPE="..."

# Apply changes
source ~/.bashrc
```

---

## Verification Checklist

After uninstallation, verify:

```bash
# No skill directory
ls ~/.openclaw/skills/feishu-notifier 2>/dev/null && echo "FAIL: Still exists" || echo "OK: Removed"

# No global notify
which notify 2>/dev/null && echo "FAIL: Still exists" || echo "OK: Removed"

# No crontab entries
crontab -l | grep -q feishu && echo "FAIL: Still exists" || echo "OK: Removed"

# No systemd service
systemctl --user list-units | grep -q feishu && echo "FAIL: Still exists" || echo "OK: Removed"

# No environment variables
env | grep -q "FEISHU_" && echo "FAIL: Still exists" || echo "OK: Removed"
```

---

## Re-installation

After complete removal, you can reinstall:

```bash
# Core only (recommended)
openclaw skill install feishu-notifier

# With advanced capabilities
openclaw skill install feishu-notifier --with-advanced
```

---

## Troubleshooting

### "Permission denied" when removing

```bash
# Check ownership
ls -la /usr/local/bin/notify

# Remove with sudo if needed
sudo rm -f /usr/local/bin/notify
```

### "Crontab not found"

```bash
# Create empty crontab
crontab -r
```

### "Service not found" during uninstall

The service may not have been installed. Skip that step.

---

## Need Help?

Open an issue: https://github.com/crayfish-ai/feishu-notifier/issues
