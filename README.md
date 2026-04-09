# Feishu Notifier v3.0

**Safe Mode: Minimal by default, ops opt-in**

A Feishu (Lark) notification bridge designed for safety and transparency.

---

## Core Features

| Feature | Description |
|---------|-------------|
| **Message Send** | Send notifications via Feishu Open API |
| **JSON Output** | Structured output for program parsing |
| **Retry Logic** | Automatic retry on network failure |
| **Config Flexibility** | Environment variables or skill config |

## What This Skill Does NOT Do

By default, this skill does **NOT**:

- ❌ Install systemd services
- ❌ Modify crontab
- ❌ Create global `/usr/local/bin/notify` link
- ❌ Auto-discover other skills
- ❌ Inject environment variables
- ❌ Require root access for basic use

These capabilities are available as **optional add-ons** (see Advanced section).

---

## Installation

```bash
# Via ClawHub (recommended)
openclaw skill install feishu-relay

# Or manual
git clone https://github.com/crayfish-ai/feishu-relay.git
cd feishu-relay
```

## Configuration

### Environment Variables

```bash
export FEISHU_APP_ID="cli_xxxxxxxxxx"
export FEISHU_APP_SECRET="xxxxxxxxxxxxxxxxxxxxxxxx"
export FEISHU_RECEIVE_ID="ou_xxxxxxxxxxxxxxxx"
export FEISHU_RECEIVE_ID_TYPE="open_id"  # optional: open_id, user_id, chat_id, email
```

### Or Skill Config

Create `config.json` in the skill directory:

```json
{
  "appId": "cli_xxx",
  "appSecret": "xxx",
  "receiveId": "ou_xxx",
  "receiveIdType": "open_id"
}
```

**Security**: Run `chmod 600 config.json` to protect credentials.

---

## Basic Usage

```bash
# Send notification
./run.sh -t "Title" -m "Message body"

# With JSON output
./run.sh -t "Title" -m "Message" --json

# Test connection
./run.sh --test

# Check config
./run.sh --config
```

---

## Output Format

### Success

```json
{
  "success": true,
  "message_id": "om_xxxxxxxxxxxx",
  "create_time": "1234567890000"
}
```

### Error

```json
{
  "success": false,
  "error": "API_ERROR",
  "message": "Failed to send",
  "code": 99991663
}
```

---

## Advanced Capabilities (Opt-in)

For system-level integrations, see [docs/advanced.md](docs/advanced.md):

| Capability | Description | Risk |
|------------|-------------|------|
| Global notify link | Link to `/usr/local/bin/notify` | Medium |
| Crontab integration | Schedule notifications | Low |
| Systemd service | Persistent daemon | Medium |
| Auto-discovery | Find other skills' notify scripts | Low |

**All advanced features require explicit opt-in via flags or separate installation scripts.**

---

## Directory Structure

```
feishu-relay/
├── SKILL.md           # Minimal skill description
├── README.md          # This file
├── skill.json         # Skill metadata
├── run.sh             # Core entry point
├── lib/
│   └── send.py        # Python notification module
├── docs/
│   ├── advanced.md     # Advanced capabilities (opt-in)
│   ├── security.md     # Security considerations
│   └── uninstall.md    # Clean removal guide
└── LICENSE
```

---

## Security

See [docs/security.md](docs/security.md) for:

- Permission boundaries
- Credential storage recommendations
- Production installation risks

---

## Uninstallation

See [docs/uninstall.md](docs/uninstall.md) for complete removal instructions.

---

## License

MIT - See LICENSE file
