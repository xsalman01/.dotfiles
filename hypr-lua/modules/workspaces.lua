-- ===========================
-- WORKSPACE RULES
-- ===========================

-- HDMI-A-1 workspaces
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true, default_name = "nvim" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default_name = "zen" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", default_name = "spotify" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", default_name = "movies" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", default_name = "misc" })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1", default_name = "misc" })

-- ### DESKTOP START ###
hl.workspace_rule({ workspace = "7", monitor = "DVI-I-1", default_name = "photos" })
hl.workspace_rule({ workspace = "8", monitor = "DVI-I-1", default_name = "discord" })
hl.workspace_rule({ workspace = "9", monitor = "DVI-I-1", default = true, default_name = "helium" })
hl.workspace_rule({ workspace = "10", monitor = "DVI-I-1", default_name = "slack" })
-- ### DESKTOP END ###

-- ### LAPTOP START ###
-- hl.workspace_rule({ workspace = "7",  monitor = "eDP-1",                 default_name = "photos"  })
-- hl.workspace_rule({ workspace = "8",  monitor = "eDP-1",                 default_name = "discord" })
-- hl.workspace_rule({ workspace = "9",  monitor = "eDP-1", default = true, default_name = "helium"  })
-- hl.workspace_rule({ workspace = "10", monitor = "eDP-1",                 default_name = "slack"   })
-- ### LAPTOP END ###

-- ===========================
-- WINDOW RULES
-- ===========================

-- Workspace assignments (tiled)
hl.window_rule({ name = "workspace-1", workspace = "1", tile = true, match = { class = "^kitty$" } })
hl.window_rule({ name = "workspace-2", workspace = "2", tile = true, match = { class = "^zen$" } })
hl.window_rule({ name = "workspace-3", workspace = "3", tile = true, match = { class = "^(spotify|Spotify|deezer-enhanced)$" } })
hl.window_rule({ name = "workspace-4", workspace = "4", tile = true, match = { class = "^(mpv|com\\.stremio\\.stremio)$" } })
hl.window_rule({ name = "workspace-5", workspace = "5", tile = true, match = { class = "^cursor$" } })
hl.window_rule({ name = "workspace-7", workspace = "7", tile = true, match = { class = "^loupe$" } })
hl.window_rule({ name = "workspace-8", workspace = "8", tile = true, match = { class = "^discord$" } })
hl.window_rule({ name = "workspace-9", workspace = "9", tile = true, match = { class = "^helium$" } })
hl.window_rule({ name = "workspace-10", workspace = "10", tile = true, match = { class = "^(Slack|slack)$" } })

-- Catch-all: anything not claimed above → workspace 6, floating, focus on activate
hl.window_rule({
    name              = "workspace-6",
    workspace         = "6",
    float             = true,
    focus_on_activate = true,
    match             = { class = ".*" },
})

-- Zen floating dialogs (PiP, file pickers, library etc.)
hl.window_rule({
    name  = "zen-floating",
    float = true,
    match = {
        class = "^zen$",
        title =
        "^(Picture-in-Picture|Library|Extension: \\(|Enter name of file to save to.*|File Upload - .*|Save Image - .*|Open Executable File.*)",
    },
})

-- Chrome PWA windows
hl.window_rule({
    name  = "chrome-floating",
    float = true,
    match = { class = "^chrome-" },
})

-- Cursor/Electron floating dialogs
hl.window_rule({
    name  = "cursor-floating",
    float = true,
    match = { class = "^electron$", title = "^Cursor$" },
})

-- Discord splash/updater
hl.window_rule({
    name      = "discord-floating",
    workspace = "8",
    float     = true,
    match     = { class = "^discord$", title = "^(discord|Discord Updater)$" },
})

-- Utility dialogs: open wherever called, float and center, no workspace pin
hl.window_rule({
    name      = "floating-utilities",
    workspace = "unset",
    float     = true,
    center    = true,
    match     = { class = "^(swappy|xdg-desktop-portal-gtk|xdg-desktop-portal|hyprland-share-picker|com\\.gabm\\.satty)$" },
})

hl.window_rule({
    name      = "floating-pwvucontrol",
    workspace = "unset",
    float     = true,
    center    = true,
    match     = { class = ".*pwvucontrol.*" },
})

-- Inactive unfocused tiled windows: 90% opacity
hl.window_rule({
    name    = "opacity",
    opacity = "0.9 0.9",
    match   = { float = false, focus = false },
})

-- Suppress maximize for all windows
hl.window_rule({
    name           = "ignore-maximize",
    suppress_event = "maximize",
    match          = { class = ".*" },
})

-- Fix XWayland drag issues
hl.window_rule({
    name     = "xwayland-drag",
    no_focus = true,
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
})

-- ===========================
-- LAYER RULES
-- ===========================
hl.layer_rule({
    name    = "quickshell-layer",
    no_anim = true,
    match   = { namespace = "^quickshell$" },
})
