#!/bin/bash

# Create Directories
echo "--- Setting up Configs ---"
mkdir -p ~/.config/{xdg-desktop-portal,fish,niri,waybar,alacritty,fuzzel}

# Copying files
[ -d "./niri" ] && cp -v ./niri/config.kdl ~/.config/niri/
[ -d "./waybar" ] && cp -v ./waybar/*.{jsonc,css} ~/.config/waybar/
[ -d "./alacritty" ] && cp -v ./alacritty/alacritty.toml ~/.config/alacritty/
[ -d "./fuzzel" ] && cp -v ./fuzzel/fuzzel.ini ~/.config/fuzzel/

# Copy Wallpaper
echo "--- Setting up Wallpaper ---"
mkdir -p ~/Pictures/Wallpaper
if [ -f "./wallpaper/*" ]; then
    cp -v ./wallpaper/* ~/Pictures/Wallpaper/
else
    echo "Warning: No wallpaper found, skipping copy."
fi

# Fish Config
cat <<EOF > ~/.config/fish/config.fish
function rwb
    killall waybar
    waybar > /dev/null 2>&1 &
    disown
    echo "Waybar reloaded!"
end
EOF

# Fish
echo "--- Installing Fish Plugins ---"
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install IlanCosman/tide@v6"
