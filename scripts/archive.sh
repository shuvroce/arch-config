#!/bin/bash

# 1. Get the directory of the first selected file
# This ensures the zip is created in the same folder as your files
BASE_DIR=$(dirname "$(readlink -f "$1")")
cd "$BASE_DIR" || exit

# 2. Ask for the name
SUGGESTED_NAME=$(basename "$BASE_DIR").zip
ARCHIVE_NAME=$(zenity --entry --title="Create Archive" --text="Enter archive name:" --entry-text="$SUGGESTED_NAME")

[ -z "$ARCHIVE_NAME" ] && exit 0 

[[ "$ARCHIVE_NAME" != *.zip ]] && ARCHIVE_NAME="${ARCHIVE_NAME}.zip"

# 3. Handle duplicate names
if [ -f "$ARCHIVE_NAME" ]; then
    ARCHIVE_NAME="${ARCHIVE_NAME%.*}_$(date +%H%M%S).zip"
fi

# 4. Zip and capture errors
# We use PIPESTATUS to check if 'zip' actually worked
zip -r "$ARCHIVE_NAME" "$@" | zenity --progress --title="Archiving" --text="Compressing to $ARCHIVE_NAME..." --pulsate --auto-close

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    notify-send "Compression Complete" "Created $ARCHIVE_NAME in $BASE_DIR"
else
    zenity --error --text="Compression failed! Check if the files are in use or if you have write permissions."
fi