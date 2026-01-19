#!/bin/bash

# Create Directories
echo "--- Setting up Configs ---"
mkdir -p ~/.config/{xdg-desktop-portal,fish,niri,waybar,alacritty,swaync}

# Copying files
[ -d "./niri" ] && cp -v ./niri/config.kdl ~/.config/niri/
[ -d "./waybar" ] && cp -v ./waybar/*.{jsonc,css} ~/.config/waybar/
[ -d "./alacritty" ] && cp -v ./alacritty/alacritty.toml ~/.config/alacritty/
[ -d "./swaync" ] && cp -v ./swaync/style.css ~/.config/swaync/

# Copy Wallpaper
echo "--- Setting up Wallpaper ---"
mkdir -p ~/Pictures/Wallpaper
if [ -f "./wallpaper/wallpaper.jpg" ]; then
    cp -v ./wallpaper/wallpaper.jpg ~/Pictures/Wallpaper/
else
    echo "Warning: ./wallpaper/wallpaper.jpg not found, skipping copy."
fi

# Portals Config
cat <<EOF > ~/.config/xdg-desktop-portal/portals.conf
[preferred]
default=wlr;gtk
org.freedesktop.impl.portal.Screencast=gnome
org.freedesktop.impl.portal.Screenshot=gnome
EOF

# Fish Config
cat <<EOF > ~/.config/fish/config.fish
function rwb
    killall waybar
    waybar > /dev/null 2>&1 &
    disown
    echo "Waybar reloaded!"
end
EOF

# oh-my-fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install IlanCosman/tide@v6
