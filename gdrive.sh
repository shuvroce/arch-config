#!/usr/bin/env bash
set -e

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
    echo "${YELLOW}Run this script as your normal user, not as root.${NC}" >&2
    exit 1
fi

echo -e "${BLUE}=== Google Drive (Thunar + Offline + Waybar) Setup ===${NC}"

mkdir -p "$HOME/.local/bin" "$HOME/.config/rclone-offline" "$HOME/.config/systemd/user" "$HOME/GoogleDrive"

echo -e "${GREEN}[1/4] Configuring Rclone Remotes...${NC}"

if ! rclone listremotes | grep -qx "gdrive-main:"; then
    echo -e "${BLUE}Step A: Authenticate 'My Drive' (gdrive-main)${NC}"
    echo "A browser window will open. Please sign in to your Google account."
    rclone config create gdrive-main drive scope=drive
else
    echo "Remote 'gdrive-main' already exists. Skipping..."
fi

read -p "${BLUE}Do you want to link an 'Other Computer' synced folder? (y/N): ${NC}" ADD_COMP
if [[ "$ADD_COMP" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Step B: Configure 'Computers' (gdrive-computers)${NC}"
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

echo -e "${YELLOW}Creating combined 'gdrive' remote...${NC}"
rclone config delete gdrive >/dev/null 2>&1 || true
rclone config create gdrive combine upstreams="$UPSTREAMS"

echo -e "${GREEN}[2/4] Installing offline pinning script (~/.local/bin/gdrive-offline.sh)...${NC}"
install -m 755 "$SCRIPT_DIR/scripts/gdrive-offline.sh" "$HOME/.local/bin/gdrive-offline.sh"

echo -e "${GREEN}[3/4] Installing Waybar status script (~/.local/bin/waybar-gdrive.sh)...${NC}"
install -m 755 "$SCRIPT_DIR/scripts/waybar-gdrive.sh" "$HOME/.local/bin/waybar-gdrive.sh"

echo -e "${GREEN}[4/4] Setting up Systemd user services...${NC}"

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
  --rc-addr 127.0.0.1:5572 \
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
After=rclone-gdrive.service

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
systemctl --user enable rclone-gdrive.service
systemctl --user restart rclone-gdrive.service
systemctl --user enable rclone-offline-sync.timer
systemctl --user restart rclone-offline-sync.timer

echo "${GREEN}--- Google Drive Setup Complete. ---${NC}"
