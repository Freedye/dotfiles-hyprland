-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function () 
    hl.exec_cmd("hyprpaper & qs")
    hl.exec_cmd("/usr/local/bin/xembedsniproxy")
    hl.exec_cmd("openrgb --startminimized")  -- applies its own startup profile
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)