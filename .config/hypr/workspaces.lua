-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Floating steam friend list
hl.window_rule({
    name  = "floating-steam-friend-list",
    match = { class = "steam" },
    float = true,
})

hl.window_rule({
    name  = "tile-steam-friend-list",
    match = { 
        class = "steam",
        title = "Steam"
    },
    tile = true,
})

-- Floating games
hl.window_rule({
    name  = "floating-games",
    match = { class = "steam_app_.*" },
    float = true,
})

-- Floating user programs
hl.window_rule({
    name  = "floating-ProtonUp-Qt",
    match = { class = "net.davidotek.pupgui2" },
    float = true,
})

hl.window_rule({
    name  = "floating-waypaper",
    match = { class = "waypaper" },
    float = true,
})