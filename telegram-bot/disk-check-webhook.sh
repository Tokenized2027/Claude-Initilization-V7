#!/bin/bash
# disk-check-webhook.sh
# Drop-in replacement for disk-check.sh that sends alerts via Telegram webhook
# Place at ~/bin/disk-check.sh (replaces the existing one from Phase 4)
#
# Sends alerts to the Telegram bot's webhook server instead of
# directly calling the Telegram API. This centralizes all notifications
# through the bot.

WEBHOOK_URL="http://127.0.0.1:8787/webhook/alert"
THRESHOLD=85
LOCKDIR="/tmp/disk-alerts"
LOCKTIME=3600  # Only alert once per hour per mount

mkdir -p "$LOCKDIR"

df -h --output=target,pcent,avail | tail -n+2 | while read mount pct avail; do
    usage=${pct%\%}

    if [ "$usage" -ge "$THRESHOLD" ]; then
        lockfile="$LOCKDIR/$(echo "$mount" | tr '/' '_')"

        # Check if we already alerted within LOCKTIME
        if [ -f "$lockfile" ]; then
            last_alert=$(stat -c %Y "$lockfile" 2>/dev/null || echo 0)
            now=$(date +%s)
            elapsed=$((now - last_alert))
            if [ "$elapsed" -lt "$LOCKTIME" ]; then
                continue  # Skip, already alerted recently
            fi
        fi

        # Send alert via webhook
        curl -s -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"level\": \"warning\",
                \"title\": \"Disk Space Alert\",
                \"source\": \"disk-check\",
                \"message\": \"Mount: $mount\\nUsage: ${pct}\\nAvailable: $avail\"
            }" > /dev/null 2>&1

        # Update lockfile
        touch "$lockfile"
        echo "$(date): Alert sent for $mount ($pct used, $avail free)"
    fi
done
