local vars = require("variables")
local theme = vars.theme

-- ==================
-- GENERAL LAYOUT
-- ==================
hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 0,
        border_size = 0,
        col         = {
            -- active_border   = theme.active_border,
            inactive_border = theme.muted,
        },
        layout      = "scrolling",
    },
})

-- ==================
-- DECORATION
-- ==================
hl.config({
    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,
        shadow           = {
            enabled      = false,
            range        = 10,
            render_power = 4,
            offset       = "-6 6",
            color        = "rgba(000000ce)",
        },
        blur             = {
            enabled  = false,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
})

-- ==================
-- ANIMATIONS
-- ==================
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "default" })

-- ==================
-- LAYOUTS
-- ==================
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "slave",
        new_on_top = true,
        mfact      = 0.60,
    },
    scrolling = {
        column_width = 0.85,
    },
})

-- ==================
-- MISC
-- ==================
hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        vrr                      = 1,
    },
})

-- ==================
-- LAYER RULES
-- ==================
hl.layer_rule({
    name         = "noctalia",
    match        = { namespace = "noctalia-background-.*" },
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})
