#!/usr/bin/env bash
set -e

echo -e "=== Google Drive (Thunar + Offline + Waybar) Setup ==="

# 1. Interactive Rclone Remote Configuration
echo -e "[1/4] Configuring Rclone Remotes..."

if ! rclone listremotes | grep -q "^gdrive-main:$"; then
    echo -e "Step A: Authenticate 'My Drive' (gdrive-main)"
    echo "A browser window will open. Please sign in to your Google account."
    rclone config create gdrive-main drive scope=drive
else
    echo "Remote 'gdrive-main' already exists. Skipping..."
fi

read -p "Do you want to link an 'Other Computer' synced folder? (y/N): " ADD_COMP
if [[ "$ADD_COMP" =~ ^[Yy]$ ]]; then
    echo -e "Step B: Configure 'Computers' (gdrive-computers)"
    echo "1. Open https://google.com -> Click 'Computers' -> Open your PC folder."
    echo "2. Copy the Folder ID at the end of the URL (after /folders/)."
    read -p "Paste your Computer Folder ID here: " COMP_ID
    
    if [ -n "$COMP_ID" ]; then
        rclone config create gdrive-computers drive scope=drive root_folder_id="$COMP_ID" shared_with_me=false
        UPSTREAMS="\"My Drive=gdrive-main:\" \"Computers=gdrive-computers:\""
    else
        echo "No ID entered. Skipping Computers remote."
        UPSTREAMS="\"My Drive=gdrive-main:\""
    fi
else
    UPSTREAMS="\"My Drive=gdrive-main:\""
fi

echo -e "Creating combined 'gdrive' remote..."
rclone config delete gdrive >/dev/null 2>&1 || true
rclone config create gdrive combine upstreams="$UPSTREAMS"

# 2. Create Offline Pinning & Sync Script
echo -e "[2/4] Creating offline pinning script (~/.local/bin/gdrive-offline.sh)..."
cat << 'EOF' > "$HOME/.local/bin/gdrive-offline.sh"
#!/usr/bin/env bash

MOUNT_DIR="$HOME/GoogleDrive"
WATCHLIST="$HOME/.config/rclone-offline/pinned.txt"
ACTION="$1"
shift

touch "$WATCHLIST"

cache_item() {
    local target="$1"
    if [[ "$target" != "$MOUNT_DIR"* ]]; then
        notify-send "Google Drive" "Item must be inside $MOUNT_DIR"
        return
    fi

    local rel_path="${target#$MOUNT_DIR/}"

    if [ "$ACTION" == "pin" ]; then
        grep -Fxq "$rel_path" "$WATCHLIST" || echo "$rel_path" >> "$WATCHLIST"
        notify-send "Google Drive" "Downloading for offline use: $rel_path"
        
        rclone rc vfs/refresh dir="$rel_path" recursive=true >/dev/null 2>&1
        find "$target" -type f -exec cat {} + >/dev/null 2>&1
        
        notify-send "Google Drive" "Available offline: $rel_path"

    elif [ "$ACTION" == "unpin" ]; then
        grep -Fxv "$rel_path" "$WATCHLIST" > "$WATCHLIST.tmp" && mv "$WATCHLIST.tmp" "$WATCHLIST"
        rclone rc vfs/forget dir="$rel_path" >/dev/null 2>&1
        notify-send "Google Drive" "Removed offline copy: $rel_path"

    elif [ "$ACTION" == "sync" ]; then
        while IFS= read -r item; do
            [ -z "$item" ] && continue
            if [ -e "$MOUNT_DIR/$item" ]; then
                rclone rc vfs/refresh dir="$item" recursive=true >/dev/null 2>&1
                find "$MOUNT_DIR/$item" -type f -exec cat {} + >/dev/null 2>&1
            fi
        done < "$WATCHLIST"
    fi
}

if [ "$ACTION" == "sync" ]; then
    cache_item ""
else
    for item in "$@"; do
        cache_item "$item"
    done
fi
EOF
chmod +x "$HOME/.local/bin/gdrive-offline.sh"

# 3. Create Waybar Status Script
echo -e "[3/4] Creating Waybar status script (~/.local/bin/waybar-gdrive.sh)..."
cat << 'EOF' > "$HOME/.local/bin/waybar-gdrive.sh"
#!/usr/bin/env bash

MOUNT_DIR="$HOME/GoogleDrive"

if ! mountpoint -q "$MOUNT_DIR"; then
    echo '{"text": "   ", "tooltip": "Google Drive: Unmounted", "class": "unmounted"}'
    exit 0
fi

STATS=$(rclone rc core/stats --timeout 1s 2>/dev/null)

if [ -z "$STATS" ]; then
    echo '{"text": "   ", "tooltip": "Google Drive: RC API unreachable", "class": "error"}'
    exit 0
fi

TRANSFERS=$(echo "$STATS" | jq -r '.transferring | length // 0')
SPEED=$(echo "$STATS" | jq -r '.speed // 0' | numfmt --to=iec-i --suffix=B/s 2>/dev/null || echo "0B/s")

if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
    echo '{"text": "   ", "tooltip": "Google Drive: Offline Mode (Local cache active)", "class": "offline"}'
elif [ "$TRANSFERS" -gt 0 ]; then
    echo "{\"text\": \"    $TRANSFERS\", \"tooltip\": \"Google Drive: Syncing $TRANSFERS file(s) ($SPEED)\", \"class\": \"syncing\"}"
else
    PINNED_COUNT=$(grep -cve '^\s*$' "$HOME/.config/rclone-offline/pinned.txt" 2>/dev/null || echo 0)
    echo "{\"text\": \"   \", \"tooltip\": \"Google Drive: Synced ($PINNED_COUNT offline pins)\", \"class\": \"synced\"}"
fi
EOF
chmod +x "$HOME/.local/bin/waybar-gdrive.sh"

# 4. Create & Enable Systemd Services (Offline-boot ready)
echo -e "[4/4] Setting up Systemd user services..."

cat << 'EOF' > "$HOME/.config/systemd/user/rclone-gdrive.service"
[Unit]
Description=Rclone Google Drive Mount

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount gdrive: %h/GoogleDrive \
  --vfs-cache-mode full \
  --vfs-cache-max-age 8760h \
  --vfs-cache-max-size 50G \
  --vfs-read-ahead 128M \
  --dir-cache-time 5m \
  --rc \
  --rc-no-auth
ExecStop=/usr/bin/fusermount3 -u %h/GoogleDrive
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

cat << 'EOF' > "$HOME/.config/systemd/user/rclone-offline-sync.service"
[Unit]
Description=Keep pinned Google Drive folders cached offline

[Service]
Type=oneshot
ExecStart=%h/.local/bin/gdrive-offline.sh sync
EOF

cat << 'EOF' > "$HOME/.config/systemd/user/rclone-offline-sync.timer"
[Unit]
Description=Refresh pinned offline folders every 15 minutes

[Timer]
OnBootSec=2m
OnUnitActiveSec=15m

[Install]
WantedBy=timers.target
EOF

fusermount3 -uz "$HOME/GoogleDrive" 2>/dev/null || true
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
systemctl --user enable --now rclone-offline-sync.timer

