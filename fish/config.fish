# Existing Auto-login logic...
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec niri-session
    end
end

if status is-interactive
    # Commands for interactive sessions
    set -g fish_greeting ""
    
    # Aliases
    alias ls='ls --color=auto'
    alias l='ls -lah'
    alias update='yay -Syu'
    alias mirror='sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'
    
    # Initialize the visual-studio-code-bin PATH if needed
    fish_add_path /opt/visual-studio-code
end

function rwb
    pkill waybar
    spawn waybar > /dev/null 2>&1 &
    disown
    echo "Waybar reloaded!"
end