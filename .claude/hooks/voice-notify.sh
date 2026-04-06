#!/usr/bin/env bash
#
# Notification hook: voice alert when Claude needs user attention.
#

LOCKFILE="/tmp/claude-stop-hook-$(id -u).lock"
COOLDOWN=15  # seconds

# If Stop hook fired recently, skip the notification
if [ -f "$LOCKFILE" ]; then
    LOCK_TIME=$(stat -f "%m" "$LOCKFILE" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    ELAPSED=$((NOW - LOCK_TIME))
    if [ "$ELAPSED" -lt "$COOLDOWN" ]; then
        exit 0
    fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/smart-notify.sh" "Your turn"

exit 0
