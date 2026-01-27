#!/bin/bash

# Create Directories
echo "--- Setting up Configs ---"
mkdir -p ~/.config/{fish,niri,waybar,alacritty,fuzzel,Thunar,mako,qt5ct,qt6ct,wlogout}
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/qt5ct/colors
mkdir -p ~/.config/qt6ct/colors
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/Wallpaper

# Copying files
[ -d "./niri" ]           && cp -rv ./niri/config.kdl ~/.config/niri/
[ -d "./waybar" ]         && cp -rv ./waybar/* ~/.config/waybar/
[ -d "./alacritty" ]      && cp -rv ./alacritty/alacritty.toml ~/.config/alacritty/
[ -d "./fish/functions" ] && cp -rv ./fish/functions/* ~/.config/fish/functions/
[ -d "./fuzzel" ]         && cp -rv ./fuzzel/fuzzel.ini ~/.config/fuzzel/
[ -d "./Thunar" ]         && cp -rv ./Thunar/uca.xml ~/.config/Thunar/
[ -d "./mako" ]           && cp -rv ./mako/config ~/.config/mako/
[ -d "./qt5ct/colors" ]   && cp -rv ./qt5ct/colors/* ~/.config/qt5ct/colors/
[ -d "./qt6ct/colors" ]   && cp -rv ./qt6ct/colors/* ~/.config/qt6ct/colors/
[ -d "./wlogout" ]        && cp -rv ./wlogout/* ~/.config/wlogout/
[ -d "./scripts" ]        && cp -rv ./scripts/* ~/.local/bin/

# Make all local scripts executable
echo "--- Making all lcoal scripts executable ---"
if [ "$(ls -A ~/.local/bin)" ]; then
    chmod +x ~/.local/bin/*
fi

# Copy Wallpaper
echo "--- Setting up Wallpaper ---"
if ls ./wallpaper/* >/dev/null 2>&1; then
    cp -v ./wallpaper/* ~/Pictures/Wallpaper/
else
    echo "Warning: No wallpaper found."
fi

# Extract themes to ~/.themes
echo "--- Extracting themes ---"
[ -d "./themes" ] && for f in ./themes/*.zip; do sudo unzip -o -q "$f" -d /usr/share/themes; done

# Fish Config
cat <<EOF > ~/.config/fish/config.fish
fish_add_path ~/.local/bin

function rwb
    killall waybar
    waybar > /dev/null 2>&1 &
    disown
    echo "Waybar reloaded!"
end
EOF

# Fish plugins
echo "--- Installing Fish Plugins ---"
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install IlanCosman/tide@v6"


# Basic setting/service
sudo usermod -aG wheel,video,storage $USER
gsettings set org.gnome.desktop.wm.preferences button-layout ":"


# lightdm
sudo systemctl enable lightdm.service
sudo mkdir -p /usr/share/pixmaps/lightdm
if [ -d "./lightdm" ]; then
    sudo cp -rv ./lightdm/* /usr/share/pixmaps/lightdm/
    sudo chmod 755 /usr/share/pixmaps/lightdm
    sudo chmod 644 /usr/share/pixmaps/lightdm/*
fi

# Overwrite (don't append) to ensure clean config
cat <<EOF | sudo tee /etc/lightdm/lightdm.conf
[LightDM]
run-directory=/run/lightdm

[Seat:*]
greeter-session=lightdm-gtk-greeter
session-wrapper=/etc/lightdm/Xsession
user-session=niri
EOF

cat <<EOF | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background=/usr/share/pixmaps/lightdm/bg.jpg
theme-name=adw-gtk3-dark
icon-theme-name=Numix-Circle
font-name=Inter 10
default-user-image=/usr/share/pixmaps/lightdm/user.png
round-user-image=true
indicators=~host;~spacer;~clock;~spacer;~session;~power
EOF
