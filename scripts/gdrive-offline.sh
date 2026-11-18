#!/usr/bin/env bash

MOUNT_DIR="$HOME/GoogleDrive"
WATCHLIST="$HOME/.config/rclone-offline/pinned.txt"
RC_ADDR="${RCLONE_RC_ADDR:-127.0.0.1:5572}"
ACTION="${1:-}"
shift || true

mkdir -p "$(dirname "$WATCHLIST")"
touch "$WATCHLIST"

cache_item() {
    local target="$1"

    if [[ "$target" != "$MOUNT_DIR" && "$target" != "$MOUNT_DIR/"* ]]; then
        notify-send "Google Drive" "Item must be inside $MOUNT_DIR"
        return 1
    fi

    local rel_path="${target#"$MOUNT_DIR"/}"
    if [ -z "$rel_path" ]; then
        notify-send "Google Drive" "Select an item inside $MOUNT_DIR"
        return 1
    fi

    local refresh_dir="$rel_path"
    if [ -f "$target" ]; then
        refresh_dir="$(dirname "$rel_path")"
        [ "$refresh_dir" = "." ] && refresh_dir=""
    fi

    case "$ACTION" in
        pin)
            grep -Fxq -- "$rel_path" "$WATCHLIST" || echo "$rel_path" >> "$WATCHLIST"
            notify-send "Google Drive" "Downloading for offline use: $rel_path"

            rclone rc --rc-addr "$RC_ADDR" vfs/refresh dir="$refresh_dir" recursive=true >/dev/null 2>&1
            find "$target" -type f -exec cat {} + >/dev/null 2>&1

            notify-send "Google Drive" "Available offline: $rel_path"
            ;;
        unpin)
            grep -Fxv -- "$rel_path" "$WATCHLIST" > "$WATCHLIST.tmp" || true
            mv "$WATCHLIST.tmp" "$WATCHLIST"
            rclone rc --rc-addr "$RC_ADDR" vfs/forget dir="$refresh_dir" >/dev/null 2>&1
            notify-send "Google Drive" "Removed offline copy: $rel_path"
            ;;
    esac
}

case "$ACTION" in
    sync)
        while IFS= read -r item; do
            [ -z "$item" ] && continue
            if [ -e "$MOUNT_DIR/$item" ]; then
                item_dir="$item"
                [ -f "$MOUNT_DIR/$item" ] && item_dir="$(dirname "$item")"
                [ "$item_dir" = "." ] && item_dir=""
                rclone rc --rc-addr "$RC_ADDR" vfs/refresh dir="$item_dir" recursive=true >/dev/null 2>&1
                find "$MOUNT_DIR/$item" -type f -exec cat {} + >/dev/null 2>&1
            fi
        done < "$WATCHLIST"
        ;;
    pin|unpin)
        for item in "$@"; do
            cache_item "$item"
        done
        ;;
    *)
        echo "Usage: $0 {pin|unpin} <path...>" >&2
        echo "       $0 sync" >&2
        exit 1
        ;;
esac
