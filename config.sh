#!/bin/bash

# Create Directories
echo "--- Setting up Configs ---"
mkdir -p ~/.config/{fish,niri,waybar,alacritty,fuzzel,Thunar,mako,qt5ct,qt6ct,wlogout}
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/qt5ct/colors
mkdir -p ~/.config/qt6ct/colors
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/Wallpaper
# mkdir -p ~/.themes

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
# [ -d "./themes" ] && for f in ./themes/*.tar.xz; do tar -xf "$f" -C ~/.themes; done
[ -d "./themes" ] && for f in ./themes/*.zip; do unzip -o -q "$f" -d ~/.themes; done

# Remove min/max/close button from window
gsettings set org.gnome.desktop.wm.preferences button-layout ":"

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

# Fish
echo "--- Installing Fish Plugins ---"
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install IlanCosman/tide@v6"


# Basic setting/service
<<<<<<< HEAD
sudo usermod -aG wheel,video,storage,vboxsf $USER


# lightdm
sudo systemctl enable --now lightdm.service
sudo mkdir -p /usr/share/pixmaps/lightdm
[ -d "./lightdm" ] && cp -rv ./lightdm/* /usr/share/pixmaps/lightdm/

cat <<EOF | sudo tee -a /etc/lightdm/lightdm.conf

[Seat:*]
greeter-session=lightdm-gtk-greeter
EOF

cat <<EOF | sudo tee -a /etc/lightdm/lightdm-gtk-greeter.conf

[greeter]
background=/usr/share/pixmaps/lightdm/bg.jpg
theme-name=adw-gtk3-dark
icon-theme-name=Numix-Circle
font-name=Inter 10
default-user-image=/usr/share/pixmaps/lightdm/user.png
round-user-image=true
EOF
=======
sudo systemctl enable --now lightdm.service
sudo usermod -aG wheel,video,storage $USER
>>>>>>> 6895ea6ed68acaf48333f7a073fa24873dd65140
