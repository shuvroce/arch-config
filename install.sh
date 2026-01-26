#!/bin/bash

# Refresh package database
sudo pacman -Syu --noconfirm

# Install Pacman Packages
echo "--- Installing Pacman Packages ---"
PKGS=(
    # System Core & Drivers
    base-devel xwayland-satellite xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-utils 
    polkit-gnome udiskie 
    
    # Niri Environment
    niri waybar fuzzel mako swaybg swayidle swaylock
    alacritty wl-clipboard cliphist wlsunset playerctl
    
    # Tools & Shell
    curl wget git fish btop fastfetch nano micro gedit
    pacman-contrib timeshift reflector
    ddcutil brightnessctl nethogs
    
    # Networking & Audio
    iwd openssh wireguard-tools wireplumber
    
    # File Management (The Thunar Stack)
    thunar gvfs gvfs-mtp tumbler ffmpegthumbnailer 
    
    # Media & Graphics
    vlc vlc-plugins-all firefox ristretto zathura evince gnome-disk-utility
    yt-dlp ffmpeg nwg-look nwg-menu waypaper
    ifuse usbmuxd libplist libimobiledevice
    
    # Fonts & Themes
    inter-font ttf-jetbrains-mono-nerd otf-codenewroman-nerd
    adw-gtk-theme libappindicator-gtk3 qt5ct qt6ct
    
    # Archives
    tar bzip2 gzip unzip unrar 7zip

    # Development
    python-pip nodejs

    # Greeter
    lightdm lightdm-gtk-greeter
)

for pkg in "${PKGS[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg" || echo "Package $pkg not found, skipping..."
done

# Install Yay
echo "--- Installing Yay ---"
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
fi

# Install AUR Packages
echo "--- Installing AUR Packages ---"
yay -S --noconfirm waypaper wlogout visual-studio-code-bin google-chrome numix-circle-icon-theme-git

# Basic setting/service
sudo systemctl enable --now lightdm.service
sudo usermod -aG wheel,video,storage,vboxsf $USER
