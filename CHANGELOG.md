# Changelog

All notable changes to this project will be documented in this file.

## [3.1.0] - 2026-04-10

### Added

- **System Pause Mechanism**: Global pause flag support for all scripts
- **Auto-load Config**: Automatic config.json loading from skill directory
- **Health-check Integration**: health-check.sh integrated with system pause

### Changed

- **notify wrapper**: Fixed absolute path resolution for system-level calls
- **run.sh**: Now sets FEISHU_SKILL_DIR for config discovery
- **self-evolution.sh**: Enhanced with pause/resume notifications

### Fixed

- **notify path issue**: `/usr/local/bin/notify` now works correctly via symlink
- **config loading**: Config auto-loads from skill directory when called from any path

### Security

- Default mode remains minimal permissions (opt-in for production features)
- Production mode capabilities remain opt-in

---

## [3.0.1] - 2026-04-09

### Added

- **docs/production.md**: Production deployment guide with recommended architecture
- **scripts/install-watchdog.sh**: Health monitoring for 24/7 servers
- `--health` CLI option for watchdog health checks

### Changed

- README: Clear distinction between default mode and production mode
- skill.json: Added `watchdog` to opt_in capabilities

### Fixed

- Consistent naming: All references changed from `feishu-notifier` to `feishu-relay`

---

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
