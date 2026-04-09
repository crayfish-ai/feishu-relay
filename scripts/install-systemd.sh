#!/bin/bash
#=============================================================================
# Systemd Service Installer
# Opt-in only: Creates user systemd service
#=============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
NOTIFY_SCRIPT="${SKILL_DIR}/run.sh"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/feishu-relay.service"

usage() {
    echo "Usage: $0 --install | --uninstall | --dry-run | --help"
    echo ""
    echo "Options:"
    echo "  --install     Install systemd user service"
    echo "  --uninstall   Remove systemd user service"
    echo "  --dry-run     Show what would be done"
    echo "  --help        Show this help"
    echo ""
    echo "NOTE: Creates a USER service, not system service"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

ACTION=""
DRY_RUN=false

while [ $# -gt 0 ]; do
    case "$1" in
        --install) ACTION="install" ;;
        --uninstall) ACTION="uninstall" ;;
        --dry-run) DRY_RUN=true ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

SERVICE_CONTENT="[Unit]
Description=Feishu Notifier Service
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${NOTIFY_SCRIPT} --daemon
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
"

do_install() {
    if [ ! -f "$NOTIFY_SCRIPT" ]; then
        echo "Error: notify script not found: $NOTIFY_SCRIPT"
        exit 1
    fi
    
    # Check if already installed
    if [ -f "$SERVICE_FILE" ]; then
        echo "Warning: Service already installed at $SERVICE_FILE"
        echo "Run --uninstall first to remove existing service"
        exit 1
    fi
    
    echo "Creating service directory: $SERVICE_DIR..."
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would create: $SERVICE_DIR"
    else
        mkdir -p "$SERVICE_DIR"
    fi
    
    echo "Installing service file: $SERVICE_FILE..."
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would create service file with content:"
        echo "$SERVICE_CONTENT" | head -5
        echo "  ..."
    else
        echo "$SERVICE_CONTENT" > "$SERVICE_FILE"
        chmod 644 "$SERVICE_FILE"
        
        # Reload systemd
        systemctl --user daemon-reload
        echo "Installed successfully"
        echo ""
        echo "To enable and start:"
        echo "  systemctl --user enable feishu-relay"
        echo "  systemctl --user start feishu-relay"
    fi
}

do_uninstall() {
    echo "Removing feishu-relay service..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would remove: $SERVICE_FILE"
    else
        # Stop if running
        systemctl --user stop feishu-relay 2>/dev/null || true
        systemctl --user disable feishu-relay 2>/dev/null || true
        
        # Remove service file
        if [ -f "$SERVICE_FILE" ]; then
            rm -f "$SERVICE_FILE"
            systemctl --user daemon-reload
            echo "Removed successfully"
        else
            echo "Service file not found, nothing to remove"
        fi
    fi
}

case "$ACTION" in
    install) do_install ;;
    uninstall) do_uninstall ;;
    *) echo "Error: No action specified"; usage; exit 1 ;;
esac
