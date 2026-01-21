function pacman
    # Check if the first argument is a command that requires root
    switch $argv[1]
        case '-S*' '-R*' '-U*' '-D*'
            sudo /usr/bin/pacman $argv
        case '*'
            /usr/bin/pacman $argv
    end
end