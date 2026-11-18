-- Set programs that you use
terminal    = "kitty"
fileManager = "env GTK_THEME=wal-flat pcmanfm"
menu        = "pidof wofi || wofi"
lockscreen  = "qs -n -p ~/.config/quickshell/lock/shell.qml"
screenshoot = 'grim -g "$(slurp)" - | tee -a "$(xdg-user-dir PICTURES)/Screenshot/Screenshot $(date +%c)" | wl-copy -t image/png'
