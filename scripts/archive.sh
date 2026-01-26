#!/bin/bash

# Use the name of the current directory for the archive name
ARCHIVE_NAME=$(basename "$PWD").zip

# If the archive already exists, add a timestamp
if [ -f "$ARCHIVE_NAME" ]; then
    ARCHIVE_NAME="$(basename "$PWD")_$(date +%H%M%S).zip"
fi

echo "Creating archive: $ARCHIVE_NAME"

# Zip the selected files
zip -r "$ARCHIVE_NAME" "$@"

notify-send "Compression Complete" "Created $ARCHIVE_NAME"