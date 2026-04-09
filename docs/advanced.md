# Advanced Capabilities (Opt-In)

These capabilities are **NOT** installed by default. They require explicit opt-in.

---

## 1. Global Notify Link

**Risk**: Medium - Creates a system-wide executable

### What it does
Creates `/usr/local/bin/notify` that wraps the feishu-relay.

### Installation

```bash
./scripts/install-global-notify.sh --install
```

### Uninstallation

```bash
./scripts/install-global-notify.sh --uninstall
```

### Usage after install

```bash
notify -t "Title" -m "Message"
```

---

## 2. Crontab Integration

**Risk**: Low - User's own crontab only

### What it does
Adds entries to current user's crontab for scheduled notifications.

### Installation

```bash
./scripts/install-crontab.sh --install --cron="0 9 * * *"
```

### Uninstallation

```bash
./scripts/install-crontab.sh --uninstall
```

### Verify crontab

```bash
crontab -l | grep feishu
```

---

## 3. Systemd Service

**Risk**: Medium - Creates persistent system service

### What it does
Installs a systemd user service for daemon mode.

### Installation

```bash
./scripts/install-systemd.sh --install --user
```

### Uninstallation

```bash
./scripts/install-systemd.sh --uninstall
```

### Usage

```bash
systemctl --user start feishu-relay
systemctl --user status feishu-relay
```

---

## 4. Auto-Discovery

**Risk**: Low - Read-only scan of known directories

### What it does
Scans common directories for other skills' notify scripts and creates convenience links.

### Installation

```bash
./scripts/install-discovery.sh --install
```

### Directories scanned

- `~/.openclaw/workspace/*/scripts/*.sh`
- `~/.openclaw/skills/*/scripts/*.sh`

### Uninstallation

```bash
./scripts/install-discovery.sh --uninstall
```

---

## Installation Scripts

All installation scripts support:

```bash
--install     # Install the capability
--uninstall   # Remove the capability
--dry-run     # Show what would be done without making changes
--help        # Show usage
```

### Pre-install checklist

Before using any advanced capability:

1. ✅ Read this document
2. ✅ Understand the risk
3. ✅ Backup current configuration
4. ✅ Test in non-production environment first
5. ✅ Confirm you have necessary permissions

---

## Combining Capabilities

You can combine capabilities:

```bash
# Install multiple capabilities
./scripts/install-global-notify.sh --install
./scripts/install-crontab.sh --install --cron="0 9 * * *"
```

Or use the combined installer:

```bash
./scripts/install-full.sh --install --capabilities=notify,crontab
```
