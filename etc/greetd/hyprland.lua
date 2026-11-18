-- Minimal Hyprland used only to host the lain greeter (runs as user "greeter").
-- Installed to /etc/greetd/hyprland.lua

-- Login only on DP-1; DP-2 stays off until the session starts.
hl.monitor({ output = "DP-1", mode = "1920x1080@180", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", disabled = true })
hl.monitor({ output = "",     mode = "preferred",     position = "auto", scale = 1 })

hl.env("XDG_STATE_HOME", "/var/lib/lain-greeter")  -- remembers last user/session
hl.env("LAIN_PRIMARY", "DP-1")                      -- monitor with the login form
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    input = {
        kb_layout = "it",
        follow_mouse = 1,
        accel_profile = "flat",
    },
    animations = { enabled = false },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

hl.on("hyprland.start", function ()
    -- When the greeter quits (login done), close this compositor so greetd starts the session.
    hl.exec_cmd("quickshell -p /etc/greetd/lain-greeter/shell.qml; hyprctl dispatch 'hl.dsp.exit()'")
end)
