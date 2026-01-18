#!/bin/bash

# 1. Install Pacman Packages
echo "--- Installing Pacman Packages ---"
sudo pacman -Syu --needed --noconfirm \
curl wget git niri xwayland-satellite xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-wlr \
xdg-desktop-portal-gtk alacritty neofetch nano micro neovim fish btop polkit-gnome pacman-contrib timeshift \
reflector networkmanager network-manager-applet thunar gvfs tumbler vlc firefox swaybg ddcutil brightnessctl \
wireplumber wl-clipboard cliphist fuzzel swaync cava wlsunset evince gedit glances udiskie qt6-multimedia-ffmpeg \
ifuse usbmuxd libplist libimobiledevice inter-font ttf-jetbrains-mono-nerd tar bzip2 gzip unzip unrar \
wireguard-tools localsend waybar playerctl libappindicator-gtk3

# 2. Install Yay (AUR Helper)
echo "--- Installing Yay ---"
sudo pacman -S --needed --noconfirm base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay

# 3. Install AUR Packages
echo "--- Installing AUR Packages ---"
yay -S --noconfirm paru wlogout nwg-look unimatrix-git visual-studio-code-bin

# 4. Create Directories & Copy Local Configs
echo "--- Setting up Configs ---"
mkdir -p ~/.config/{xdg-desktop-portal,fish,niri,waybar,alacritty,swaync}

# Copying files from the local directory where install.sh is located
[ -d "./niri" ] && cp -v ./niri/config.kdl ~/.config/niri/
[ -d "./waybar" ] && cp -v ./waybar/*.{jsonc,css} ~/.config/waybar/
[ -d "./alacritty" ] && cp -v ./alacritty/alacritty.toml ~/.config/alacritty/

# 4.5 Copy Wallpaper
echo "--- Setting up Wallpaper ---"
mkdir -p ~/Pictures/Wallpaper
if [ -f "./wallpaper/wallpaper.jpg" ]; then
    cp -v ./wallpaper/wallpaper.jpg ~/Pictures/Wallpaper/
else
    echo "Warning: ./wallpaper/wallpaper.jpg not found, skipping copy."
fi

# 5. Write Portals Config
cat <<EOF > ~/.config/xdg-desktop-portal/portals.conf
[preferred]
default=wlr;gtk
org.freedesktop.impl.portal.Screencast=gnome
org.freedesktop.impl.portal.Screenshot=gnome
EOF

# 6. Set up Fish Config
cat <<EOF > ~/.config/fish/config.fish
if status is-login
    if test -z "\$DISPLAY" -a "\$XDG_VTNR" = 1
        exec niri-session
    end
end

function rwb
    killall waybar
    waybar > /dev/null 2>&1 &
    disown
    echo "Waybar reloaded!"
end
EOF

# 7. Set up Auto-login for Getty
echo "--- Setting up Auto-login ---"
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo bash -c "cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --o '-p -- \\\\u' --noclear --autologin $USER %I \$TERM
EOF"

# Change shell to fish
FISH_PATH=$(which fish)
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
sudo chsh -s "$FISH_PATH" $USER

echo "--- Setup Complete! System will now reboot in 5 seconds ---"
sleep 5
reboot