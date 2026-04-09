#!/bin/bash
#=============================================================================
# Global Notify Link Installer
# Opt-in only: Creates /usr/local/bin/notify wrapper
#=============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIFY_SOURCE="${SCRIPT_DIR}/../notify"
TARGET_PATH="/usr/local/bin/notify"
USER_TARGET_PATH="${HOME}/bin/notify"

usage() {
    echo "Usage: $0 --install | --uninstall | --dry-run | --help"
    echo ""
    echo "Options:"
    echo "  --install     Install global notify link"
    echo "  --uninstall   Remove global notify link"
    echo "  --dry-run     Show what would be done"
    echo "  --help        Show this help"
    echo ""
    echo "WARNING: This modifies /usr/local/bin/notify"
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

if [ -z "$ACTION" ]; then
    echo "Error: No action specified"
    usage
    exit 1
fi

do_install() {
    if [ ! -f "$NOTIFY_SOURCE" ]; then
        echo "Error: notify source not found: $NOTIFY_SOURCE"
        exit 1
    fi
    
    # Check if target already exists
    if [ -f "$TARGET_PATH" ]; then
        echo "Warning: $TARGET_PATH already exists"
        echo "Backing up to ${TARGET_PATH}.bak"
        if [ "$DRY_RUN" = false ]; then
            sudo cp "$TARGET_PATH" "${TARGET_PATH}.bak"
        fi
    fi
    
    echo "Installing notify to $TARGET_PATH..."
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would copy: $NOTIFY_SOURCE -> $TARGET_PATH"
    else
        sudo cp "$NOTIFY_SOURCE" "$TARGET_PATH"
        sudo chmod +x "$TARGET_PATH"
        echo "Installed successfully"
    fi
}

do_uninstall() {
    if [ -f "$TARGET_PATH" ]; then
        echo "Removing $TARGET_PATH..."
        if [ "$DRY_RUN" = true ]; then
            echo "  [DRY RUN] Would remove: $TARGET_PATH"
        else
            sudo rm -f "$TARGET_PATH"
            echo "Removed successfully"
        fi
    else
        echo "$TARGET_PATH not found, nothing to remove"
    fi
    
    # Also check user directory
    if [ -f "$USER_TARGET_PATH" ]; then
        echo "Removing $USER_TARGET_PATH..."
        if [ "$DRY_RUN" = true ]; then
            echo "  [DRY RUN] Would remove: $USER_TARGET_PATH"
        else
            rm -f "$USER_TARGET_PATH"
            echo "Removed successfully"
        fi
    fi
}

case "$ACTION" in
    install) do_install ;;
    uninstall) do_uninstall ;;
esac
