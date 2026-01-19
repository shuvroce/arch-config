#!/bin/bash

# Install Pacman Packages
echo "--- Installing Pacman Packages ---"
sudo pacman -Syu --needed --noconfirm \
curl wget git xwayland-satellite xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-wlr \
xdg-desktop-portal-gtk alacritty neofetch nano micro neovim fish btop polkit-gnome pacman-contrib timeshift \
reflector network-manager-applet thunar gvfs tumbler vlc firefox swaybg ddcutil brightnessctl \
wireplumber wl-clipboard cliphist fuzzel swaync swayloack cava wlsunset evince gedit glances udiskie qt6-multimedia-ffmpeg \
ifuse usbmuxd libplist libimobiledevice inter-font ttf-jetbrains-mono-nerd tar bzip2 gzip unzip unrar \
wireguard-tools localsend waybar playerctl libappindicator-gtk3

# Install Yay (AUR Helper)
echo "--- Installing Yay ---"
sudo pacman -S --needed --noconfirm base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay

# Install niri
echo "--- Installing niri ---"
yay -S --noconfirm niri

# Install AUR Packages
echo "--- Installing AUR Packages ---"
yay -S --noconfirm waypaper wlogout nwg-look unimatrix-git visual-studio-code-bin

# Install sddm (login manager)
echo "--- Installing Display Manager (sddm) ---"
sudo pacman -S sddm
sudo systemctl enable sddm.service
sudo systemctl start sddm.service
