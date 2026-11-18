-- Set programs that you use
terminal    = "kitty"
fileManager = "env GTK_THEME=wal-flat pcmanfm"
menu        = "qs ipc call launcher toggle"
lockscreen  = "qs -n -p ~/.config/quickshell/lock/shell.qml"
screenshoot = 'grim -g "$(slurp)" - | tee -a "$(xdg-user-dir PICTURES)/Screenshot/Screenshot $(date +%c)" | wl-copy -t image/png'
