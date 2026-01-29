#!/bin/bash

# Ask user for the archive name
ARCHIVE_NAME=$(zenity --entry --title="Create Archive" --text="Enter archive name:" --entry-text="$(basename "$PWD").zip")

[ -z "$ARCHIVE_NAME" ] && exit 0 # Exit if user hits cancel

# Ensure it ends in .zip
[[ "$ARCHIVE_NAME" != *.zip ]] && ARCHIVE_NAME="${ARCHIVE_NAME}.zip"

# Zip with a progress pulse
zip -r "$ARCHIVE_NAME" "$@" | zenity --progress --title="Archiving" --text="Compressing files..." --pulsate --auto-close

notify-send "Compression Complete" "Created $ARCHIVE_NAME"