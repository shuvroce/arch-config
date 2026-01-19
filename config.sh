# Create Directories & Copy Local Configs
echo "--- Setting up Configs ---"
mkdir -p ~/.config/{xdg-desktop-portal,fish,niri,waybar,alacritty,swaync}

# Copying files from the local directory where install.sh is located
[ -d "./niri" ] && cp -v ./niri/config.kdl ~/.config/niri/
[ -d "./waybar" ] && cp -v ./waybar/*.{jsonc,css} ~/.config/waybar/
[ -d "./alacritty" ] && cp -v ./alacritty/alacritty.toml ~/.config/alacritty/

# Copy Wallpaper
echo "--- Setting up Wallpaper ---"
mkdir -p ~/Pictures/Wallpaper
if [ -f "./wallpaper/wallpaper.jpg" ]; then
    cp -v ./wallpaper/wallpaper.jpg ~/Pictures/Wallpaper/
else
    echo "Warning: ./wallpaper/wallpaper.jpg not found, skipping copy."
fi

# Write Portals Config
cat <<EOF > ~/.config/xdg-desktop-portal/portals.conf
[preferred]
default=wlr;gtk
org.freedesktop.impl.portal.Screencast=gnome
org.freedesktop.impl.portal.Screenshot=gnome
EOF

# Fish Config
cat <<EOF > ~/.config/fish/config.fish
# if status is-login
#     if test -z "\$DISPLAY" -a "\$XDG_VTNR" = 1
#         exec niri-session
#     end
# end

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



# 7. Set up Auto-login for Getty
# echo "--- Setting up Auto-login ---"
# sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
# sudo bash -c "cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
# [Service]
# ExecStart=
# ExecStart=-/sbin/agetty --o '-p -- \\\\u' --noclear --autologin $USER %I \$TERM
# EOF"