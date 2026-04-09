# Production Deployment Guide

## Two Modes: Default vs Production

feishu-relay supports two deployment modes:

| Aspect | Default Mode | Production Mode |
|--------|-------------|-----------------|
| **Installation** | ClawHub / one-liner | Manual + opt-in |
| **System Integration** | None | systemd + watchdog |
| **Persistence** | Per-session or cron | Daemon + auto-restart |
| **Use Case** | Personal / testing | 24/7 server |
| **Risk** | Minimal | Contained (user-level) |

---

## Default Mode (ClawHub Install)

```bash
openclaw skill install feishu-relay
```

**What you get:**
- ✅ Send messages via `./run.sh` or `notify` command
- ✅ JSON structured output
- ✅ Retry on failure
- ❌ No systemd
- ❌ No crontab
- ❌ No auto-discovery
- ❌ No global notify link

**Safe for:**
- Personal computers
- Shared hosting
- Testing/development
- ClawHub distribution

---

## Production Mode (Self-Hosted Server)

For your own Linux server with 24/7 uptime requirements.

### Recommended Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Your Linux Server                       │
│                                                              │
│  ┌──────────────────┐     ┌──────────────────────────────┐ │
│  │    OpenClaw      │────▶│      feishu-relay            │ │
│  │  (AI Assistant)  │     │  (Notification Bridge)       │ │
│  │                  │     │                              │ │
│  │  • Brain         │     │  • /usr/local/bin/notify     │ │
│  │  • Scheduling    │     │  • systemd (watchdog)       │ │
│  │  • Skills        │     │  • Health monitoring         │ │
│  └──────────────────┘     └──────────────────────────────┘ │
│                                      │                       │
│                                      ▼                       │
│                              ┌──────────────┐                │
│                              │  Feishu API  │                │
│                              └──────────────┘                │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  systemd user service (feishu-relay.service)          │   │
│  │  • Restart=on-failure                                 │   │
│  │  • RestartSec=5s                                     │   │
│  │  • ExecStart=/path/to/run.sh                          │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Watchdog timer (cron-based health check)             │   │
│  │  • Every 5 min: Check if relay is responsive         │   │
│  │  • If dead: Restart via systemctl                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### What Production Mode Adds

| Capability | File | Purpose |
|-----------|------|---------|
| **Systemd service** | `feishu-relay.service` | 24/7 daemon with auto-restart |
| **Watchdog cron** | Health check script | Detect and recover from hangs |
| **Global notify** | `/usr/local/bin/notify` | System-wide notification command |
| **Crontab** | Scheduled health checks | Periodic availability monitoring |

### Production Capability Details

#### 1. Systemd Service (Recommended for 24/7)

**Use when:**
- Server runs 24/7
- Need automatic restart on crash
- Want to monitor via `systemctl status`
- Need startup on boot

```bash
# Install systemd service (user-level)
./scripts/install-systemd.sh --install --user

# Enable at login
loginctl enable-linger $(whoami)

# Start now
systemctl --user start feishu-relay

# Check status
systemctl --user status feishu-relay
```

**Service file location:** `~/.config/systemd/user/feishu-relay.service`

#### 2. Watchdog / Health Check

**Use when:**
- Server may have memory leaks
- Need early detection of failures
- Want SMS/alert on prolonged downtime

```bash
# Install watchdog cron (every 5 minutes)
./scripts/install-watchdog.sh --install --interval=5
```

**What it checks:**
- Process is running
- API responds within timeout
- No repeated failures

**If check fails:**
1. Try graceful restart
2. If still failing after 3 attempts → send alert

#### 3. Global Notify Link

**Use when:**
- Multiple scripts need to send notifications
- Want consistent `/usr/local/bin/notify` interface
- Don't want to remember feishu-relay path

```bash
# Install (requires root or sudo)
sudo ./scripts/install-global-notify.sh --install

# Now any script can use:
notify -t "Title" -m "Message"
```

### Production Installation Steps

```bash
# 1. Install base (from ClawHub or git)
openclaw skill install feishu-relay

# 2. Configure
export FEISHU_APP_ID="cli_xxx"
export FEISHU_APP_SECRET="xxx"
export FEISHU_RECEIVE_ID="ou_xxx"

# 3. Test basic functionality
./run.sh --test

# 4. Enable systemd (for 24/7)
./scripts/install-systemd.sh --install --user

# 5. Enable watchdog (recommended)
./scripts/install-watchdog.sh --install --interval=5

# 6. Verify
systemctl --user status feishu-relay
crontab -l | grep feishu-relay
```

### OpenClaw's Role in Production

```
┌────────────────────────────────────────────────────────────┐
│                         OpenClaw                           │
│                                                          │
│  • Brain: AI processing & decision making                │
│  • Scheduler: Cron-based skill triggers                   │
│  • Skills: Modular capabilities                           │
│  • Gateway: Message routing (Telegram/Feishu/etc.)        │
│                                                          │
│         ▲                    ▲                    ▲       │
│         │                    │                    │       │
│    User Commands      Notification Relay       External APIs│
└─────────┼────────────────────┼────────────────────┼───────┘
          │                    │                    │
          ▼                    ▼                    ▼
    ┌─────────┐          ┌──────────┐          ┌─────────┐
    │  Shell  │          │ feishu-  │          │ Feishu  │
    │ Scripts │          │ relay    │──────────│   API   │
    └─────────┘          └──────────┘          └─────────┘
                              ▲
                              │
                    /usr/local/bin/notify
```

**OpenClaw is the brain** - decides when to notify
**feishu-relay is the bridge** - reliably delivers messages

---

## Security Considerations

### Default Mode
- ✅ No system modifications
- ✅ No root required
- ✅ Isolated to skill directory

### Production Mode
- ⚠️ Systemd service (user-level, contained)
- ⚠️ Global /usr/local/bin/notify (requires root)
- ⚠️ Crontab entries (user-level, contained)

**All production capabilities are:**
1. User-level, not system-wide (except global notify)
2. Explicit opt-in only
3. Documented with clear risk assessment
4. Removable via --uninstall

---

## Troubleshooting Production Setup

### Service won't start

```bash
# Check logs
journalctl --user -u feishu-relay -n 50

# Verify config
cat ~/.openclaw/skills/feishu-relay/config.json

# Test manually
./run.sh --test
```

### Watchdog keeps restarting

```bash
# Check failure reason
cat ~/.openclaw/skills/feishu-relay/logs/watchdog.log

# Temporarily disable watchdog
./scripts/install-watchdog.sh --uninstall
```

### Global notify not found

```bash
# Verify installation
ls -la /usr/local/bin/notify

# Reinstall if needed
sudo ./scripts/install-global-notify.sh --install
```
