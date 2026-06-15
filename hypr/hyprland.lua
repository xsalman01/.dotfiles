local vars = require("variables")
--[[
  ==================
    MONITOR CONFIG
  ==================
--]]

-- ### LAPTOP START ###
hl.monitor({
    output = "HDMI-A-1",
    position = "0x0",
    mode = "preferred",
    scale = 1
})

hl.monitor({
    output = "eDP-1",
    position = "auto",
    mode = "preferred",
    scale = 1
})
-- ### LAPTOP END ###

-- ### DESKTOP START ###
-- hl.monitor({
--     output = "HDMI-A-1",
--     position = "0x0",
--     mode = "preferred",
--     scale = 1,
-- })

-- hl.monitor({
--     output = "DVI-I-1",
--     position = "1920x90",
--     mode = "1600x900@59.01600",
--     scale = 1,
-- })
-- ### DESKTOP END ###

--[[
 ==================
  STARTUP APPS
 ==================
--]]

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hyprctl setcursor Vimix-white-cursors 24")
    hl.exec_cmd("uwsm app -- " .. vars.zen)
    hl.exec_cmd("uwsm app -- qs -c noctalia-shell")
    hl.exec_cmd("hypridle")

    -- ### DESKTOP START ###
    -- hl.exec_cmd(vars.home .. "/.dotfiles/pipewire_scripts/create_virtual_sinks.sh")
    -- hl.timer(function()
    --     hl.exec_cmd("uwsm app -- " .. vars.discord)
    -- end, { timeout = 3000, type = "oneshot" })
    -- ### DESKTOP END ###

    -- ### LAPTOP START ###
    hl.timer(function()
        hl.exec_cmd("uwsm app -- " .. vars.slack)
    end, { timeout = 3000, type = "oneshot" })

    hl.exec_cmd("uwsm app -- " .. vars.helium)
    -- ### LAPTOP END ###
end)

require("modules.audio-controls")
require("modules.binds")
require("modules.input")
require("modules.looks")
require("modules.workspaces")
