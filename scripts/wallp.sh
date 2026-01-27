#!/bin/bash
# Kill any existing wallpaper process
killall swaybg 2>/dev/null

# Set the new wallpaper (passed as an argument from Thunar)
swaybg -i "$1" -m fill &

# Save for reboot persistence
echo "killall swaybg 2>/dev/null; swaybg -i '$1' -m fill &" > ~/.config/niri/wallpaper.sh
chmod +x ~/.config/niri/wallpaper.sh