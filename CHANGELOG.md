# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0] - 2026-04-09

### Changed

- **Security First**: Complete restructure for ClawHub approval
- **Minimal by Default**: Core capability reduced to just send/retry/queue
- **Opt-in Advanced**: All system modifications moved to explicit opt-in
- **Documentation**: Separated core docs from advanced/ops docs

### Removed (by default)

- No automatic crontab installation
- No automatic systemd service setup
- No global `/usr/local/bin/notify` link creation
- No auto-discovery of other skills
- No environment variable injection
- No root requirement for basic use

### Added

- `docs/advanced.md`: Opt-in capabilities documentation
- `docs/security.md`: Security considerations
- `docs/uninstall.md`: Complete removal guide
- `SKILL.md`: Minimal skill description
- `CHANGELOG.md`: Version history

### Changed File Structure

```
feishu-relay/
├── SKILL.md           # NEW: Minimal skill description
├── README.md          # REVISED: Core + opt-in separation
├── skill.json         # REVISED: New version 3.0.0
├── lib/
│   └── send.py        # Core notification logic (unchanged)
├── docs/              # NEW directory
│   ├── advanced.md     # NEW: Opt-in capabilities
│   ├── security.md     # NEW: Security guide
│   └── uninstall.md    # NEW: Removal guide
└── scripts/           # Opt-in installers (existing advanced)
```

### Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-04-07 | Initial release |
| 2.0.0 | 2026-04-08 | Production-ready with config layering |
| 3.0.0 | 2026-04-09 | Safe mode: minimal + opt-in |

---

## [2.0.0] - 2026-04-08

### Added

- Python JSON processing module
- Config file support (skill.json)
- Environment variable support
- Retry with exponential backoff
- Structured JSON output
- Comprehensive test suite

### Changed

- Refactored to Python core
- Improved error handling
- Enhanced logging

---

## [1.0.0] - 2026-04-07

### Added

- Basic notification sending
- Shell script interface
- Environment variable configuration
