#!/usr/bin/env bash

MOUNT_DIR="$HOME/GoogleDrive"
RC_ADDR="${RCLONE_RC_ADDR:-127.0.0.1:5572}"

if ! mountpoint -q "$MOUNT_DIR" 2>/dev/null; then
    echo '{"text": "   ", "tooltip": "Google Drive: Unmounted", "class": "unmounted"}'
    exit 0
fi

STATS=$(rclone rc --rc-addr "$RC_ADDR" core/stats --timeout 1s 2>/dev/null)

if [ -z "$STATS" ]; then
    echo '{"text": "   ", "tooltip": "Google Drive: RC API unreachable", "class": "error"}'
    exit 0
fi

TRANSFERS=$(echo "$STATS" | jq -r '.transferring // [] | length' 2>/dev/null)
TRANSFERS=${TRANSFERS:-0}
SPEED=$(echo "$STATS" | jq -r '.speed // 0' 2>/dev/null | numfmt --to=iec-i --suffix=B/s 2>/dev/null || echo "0B/s")

if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
    echo '{"text": "   ", "tooltip": "Google Drive: Offline Mode (Local cache active)", "class": "offline"}'
elif [ "$TRANSFERS" -gt 0 ]; then
    echo "{\"text\": \"    $TRANSFERS\", \"tooltip\": \"Google Drive: Syncing $TRANSFERS file(s) ($SPEED)\", \"class\": \"syncing\"}"
else
    PINNED_COUNT=$(grep -cve '^[[:space:]]*$' "$HOME/.config/rclone-offline/pinned.txt" 2>/dev/null)
    PINNED_COUNT=${PINNED_COUNT:-0}
    echo "{\"text\": \"   \", \"tooltip\": \"Google Drive: Synced ($PINNED_COUNT offline pins)\", \"class\": \"synced\"}"
fi
