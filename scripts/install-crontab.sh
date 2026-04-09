#!/bin/bash
#=============================================================================
# Crontab Integration Installer
# Opt-in only: Adds entries to user's crontab
#=============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIFY_SCRIPT="$(cd "$SCRIPT_DIR/.." && pwd)/run.sh"

usage() {
    echo "Usage: $0 --install [--cron='...'] | --uninstall | --dry-run | --help"
    echo ""
    echo "Options:"
    echo "  --install    Install crontab entry"
    echo "  --uninstall  Remove crontab entry"
    echo "  --dry-run    Show what would be done"
    echo "  --help       Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --install --cron='0 9 * * *'"
    echo "  $0 --install --cron='*/30 * * * *' --message='Check'"
    echo "  $0 --uninstall"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

ACTION=""
DRY_RUN=false
CRON_EXPR=""
CRON_COMMENT="# feishu-notifier"

while [ $# -gt 0 ]; do
    case "$1" in
        --install) ACTION="install" ;;
        --uninstall) ACTION="uninstall" ;;
        --dry-run) DRY_RUN=true ;;
        --cron) CRON_EXPR="$2"; shift ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

do_install() {
    if [ -z "$CRON_EXPR" ]; then
        echo "Error: --cron is required for installation"
        echo "Example: $0 --install --cron='0 9 * * *'"
        exit 1
    fi
    
    # Validate cron expression
    if ! echo "$CRON_EXPR" | grep -qE '^[0-9*,/-]+\s+[0-9*,/-]+\s+[0-9*,/-]+\s+[0-9*,/-]+\s+[0-9*,/-]+$'; then
        echo "Error: Invalid cron expression: $CRON_EXPR"
        exit 1
    fi
    
    # Check if already installed
    if crontab -l 2>/dev/null | grep -q "$CRON_COMMENT"; then
        echo "Warning: feishu-notifier crontab entry already exists"
        echo "Run --uninstall first to remove existing entry"
        exit 1
    fi
    
    echo "Installing crontab entry: $CRON_EXPR"
    
    # Create temporary crontab with new entry
    (crontab -l 2>/dev/null || true; echo "$CRON_EXPR $NOTIFY_SCRIPT --cron $CRON_COMMENT") | \
        grep -v "^$" | \
        sort -u > /tmp/feishu_crontab_$$
    
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would add to crontab:"
        echo "  $CRON_EXPR $NOTIFY_SCRIPT --cron"
    else
        crontab /tmp/feishu_crontab_$$
        rm /tmp/feishu_crontab_$$
        echo "Installed successfully"
    fi
}

do_uninstall() {
    echo "Removing feishu-notifier crontab entries..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would remove entries containing: $CRON_COMMENT"
    else
        crontab -l 2>/dev/null | grep -v "$CRON_COMMENT" | crontab -
        echo "Removed successfully"
    fi
}

case "$ACTION" in
    install) do_install ;;
    uninstall) do_uninstall ;;
    *) echo "Error: No action specified"; usage; exit 1 ;;
esac
