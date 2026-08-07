-- Set programs that you use
terminal    = "kitty"
fileManager = "pcmanfm"
menu        = "pidof wofi || wofi"
hyprlock    = "hyprlock"
screenshoot = 'grim -g "$(slurp)" - | tee -a "/home/freedye/Immagini/Screenshot/Screenshot $(date +%c)" | wl-copy -t image/png'
