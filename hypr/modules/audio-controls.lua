-- === Audio Controls ===
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_SINK@ 5%+"),
    { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"),
    { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind("F9", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("F10", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("F11", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("F12", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_SINK@ 5%+"), { repeating = true, locked = true })

-- === Spotify Controls ===
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --player=spotify next"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl --player=spotify pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player=spotify play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --player=spotify previous"), { locked = true })

hl.bind("F1", hl.dsp.exec_cmd("playerctl --player=spotify volume 0.05-"), { repeating = true, locked = true })
hl.bind("F2", hl.dsp.exec_cmd("playerctl --player=spotify volume 0.05+"), { repeating = true, locked = true })
hl.bind("F3", hl.dsp.exec_cmd("playerctl --player=spotify volume 0.0"), { locked = true })
hl.bind("F4", hl.dsp.exec_cmd("playerctl --player=spotify volume 1.0"), { locked = true })
hl.bind("F5", hl.dsp.exec_cmd("playerctl --player=spotify previous"), { locked = true })
hl.bind("F6", hl.dsp.exec_cmd("playerctl --player=spotify play-pause"), { locked = true })
hl.bind("F7", hl.dsp.exec_cmd("playerctl --player=spotify pause"), { locked = true })
hl.bind("F8", hl.dsp.exec_cmd("playerctl --player=spotify next"), { locked = true })

-- === Virtual Sinks ===
-- ### DESKTOP START ###
-- local vars = require("variables")
-- local scripts = vars.home .. "/.dotfiles/pipewire_scripts/"
-- hl.bind(vars.super .. " + F6", hl.dsp.exec_cmd(scripts .. "create_virtual_sinks.sh"))
-- 
-- hl.bind(vars.super .. " + F1", hl.dsp.exec_cmd(scripts .. "change_sink_volume.sh game_sink mute"), { repeating = true })
-- hl.bind(vars.super .. " + F2", hl.dsp.exec_cmd(scripts .. "change_sink_volume.sh game_sink down"), { repeating = true })
-- hl.bind(vars.super .. " + F3", hl.dsp.exec_cmd(scripts .. "change_sink_volume.sh game_sink up"), { repeating = true })
-- 
-- hl.bind(vars.super .. " + F10", hl.dsp.exec_cmd(scripts .. "change_sink_volume.sh chat_sink mute"), { repeating = true })
-- hl.bind(vars.super .. " + F11", hl.dsp.exec_cmd(scripts .. "change_sink_volume.sh chat_sink down"), { repeating = true })
-- hl.bind(vars.super .. " + F12", hl.dsp.exec_cmd(scripts .. "change_sink_volume.sh chat_sink up"), { repeating = true })
-- ### DESKTOP END ###
