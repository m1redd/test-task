#!/usr/bin/env bash
#
# Smart notification: auto-detects Zoom, respects manual settings.
# Usage: smart-notify.sh "Your turn"

MESSAGE="${1:-Notification}"
SETTINGS="$HOME/.trytami/settings.json"

PROJECT_NAME=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")
BRANDED_MESSAGE="${PROJECT_NAME}: ${MESSAGE}"

# 1. Check manual override
if [ -f "$SETTINGS" ]; then
    MODE=$(python3 -c "
import json
with open('$SETTINGS') as f:
    d = json.load(f)
v = d.get('sound_notifications', 'auto')
print(str(v).lower())
" 2>/dev/null || echo "auto")
else
    MODE="auto"
fi

show_banner() {
    osascript -l JavaScript -e "
var app = Application.currentApplication();
app.includeStandardAdditions = true;
app.displayNotification('${BRANDED_MESSAGE}', {withTitle: '${PROJECT_NAME}'});
" 2>/dev/null
}

if [ "$MODE" = "false" ]; then
    show_banner
    exit 0
elif [ "$MODE" = "true" ]; then
    say "$MESSAGE"
    exit 0
fi

# 2. Auto-detect Zoom (MODE = "auto")
IN_CALL=false
pgrep -x "zoom.us" > /dev/null 2>&1 && IN_CALL=true

# 3. Notify
if [ "$IN_CALL" = true ]; then
    show_banner
else
    say "$MESSAGE"
fi

exit 0
