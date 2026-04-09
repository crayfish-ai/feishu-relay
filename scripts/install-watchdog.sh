#!/bin/bash
#=============================================================================
# Watchdog Installer
# Production capability: Health monitoring for feishu-relay
#=============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CRON_MARKER="feishu-relay-watchdog"

usage() {
    echo "Usage: $0 --install [--interval=<minutes>] | --uninstall | --dry-run | --help"
    echo ""
    echo "Options:"
    echo "  --install           Install watchdog cron"
    echo "  --interval=<min>    Check interval in minutes (default: 5)"
    echo "  --uninstall         Remove watchdog cron"
    echo "  --dry-run           Show what would be done"
    echo "  --help              Show this help"
    echo ""
    echo "This is a PRODUCTION capability for 24/7 servers."
    echo "It monitors feishu-relay health and restarts if needed."
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

ACTION=""
DRY_RUN=false
INTERVAL=5
CRON_LINE="*/${INTERVAL} * * * * cd '${SKILL_DIR}' && ./run.sh --health >> '${SKILL_DIR}/logs/watchdog.log' 2>&1"

while [ $# -gt 0 ]; do
    case "$1" in
        --install) ACTION="install" ;;
        --uninstall) ACTION="uninstall" ;;
        --dry-run) DRY_RUN=true ;;
        --interval=*)
            INTERVAL="${1#*=}"
            CRON_LINE="*/${INTERVAL} * * * * cd '${SKILL_DIR}' && ./run.sh --health >> '${SKILL_DIR}/logs/watchdog.log' 2>&1"
            ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

ensure_cron_dir() {
    if [ ! -d "${SKILL_DIR}/logs" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "${SKILL_DIR}/logs"
        fi
    fi
}

do_install() {
    echo "Installing feishu-relay watchdog (every ${INTERVAL} minutes)..."
    
    ensure_cron_dir
    
    # Check if already installed
    if crontab -l 2>/dev/null | grep -q "$CRON_MARKER"; then
        echo "Watchdog already installed. Use --uninstall first."
        exit 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would add cron:"
        echo "  $CRON_LINE"
        echo "  Marker: #$CRON_MARKER"
        return
    fi
    
    # Add to crontab
    (crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "# $CRON_MARKER"; echo "$CRON_LINE") | crontab -
    
    echo "✓ Watchdog installed (every ${INTERVAL} minutes)"
    echo "  Logs: ${SKILL_DIR}/logs/watchdog.log"
    echo "  To remove: $0 --uninstall"
}

do_uninstall() {
    echo "Removing feishu-relay watchdog..."
    
    if [ "$DRY_RUN" = true ]; then
        if crontab -l 2>/dev/null | grep -q "$CRON_MARKER"; then
            echo "  [DRY RUN] Would remove watchdog cron entry"
        else
            echo "  [DRY RUN] No watchdog found"
        fi
        return
    fi
    
    crontab -l 2>/dev/null | grep -v "$CRON_MARKER" | crontab - 2>/dev/null || true
    
    echo "✓ Watchdog removed"
}

case "$ACTION" in
    install) do_install ;;
    uninstall) do_uninstall ;;
    *) echo "Error: No action specified"; usage; exit 1 ;;
esac
