return {
    home     = os.getenv("HOME"),

    -- Modifier keys
    super    = "SUPER",
    enter    = "RETURN",
    mod      = "ALT",

    -- Applications
    terminal = "kitty",
    zen      = "zen-browser",
    helium   = "helium-browser",
    slack    = "slack",
    discord  = "discord",
    spotify  = "spotify",
    code     = "cursor",

    -- ==================
    -- ROSEPINE THEME
    -- ==================
    theme    = {
        base            = "#191724ff",
        surface         = "#1f1d2eff",
        overlay         = "#26233aff",
        muted           = "#6e6a86ff",
        subtle          = "#908caaff",
        text            = "#e0def4ff",
        love            = "#eb6f92ff",
        gold            = "#f6c177ff",
        rose            = "#ebbcbaff",
        pine            = "#31748fff",
        foam            = "#9ccfd8ff",
        iris            = "#c4a7e7ff",
        highlightLow    = "#21202eff",
        highlightMed    = "#403d52ff",
        highlightHigh   = "#524f67ff",
        active_border   = "#c4a7e7fe", -- was 0xfe alpha
        inactive_border = "#4c4870aa", -- was 0xaa alpha
    }
}
