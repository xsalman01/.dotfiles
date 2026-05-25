local vars  = require("variables")

local home  = vars.home
local super = vars.super
local mod   = vars.mod

-- === Application Launchers ===
hl.bind(super .. "+" .. vars.enter, hl.dsp.exec_cmd("uwsm app -- " .. vars.terminal))
hl.bind(super .. "+ CTRL + 2", hl.dsp.exec_cmd("uwsm app -- " .. vars.zen))
hl.bind(super .. "+ CTRL + 3", hl.dsp.exec_cmd("uwsm app -- " .. vars.spotify))
hl.bind(super .. "+ CTRL + 8", hl.dsp.exec_cmd("uwsm app -- " .. vars.discord))
hl.bind(super .. "+ CTRL + 9", hl.dsp.exec_cmd("uwsm app -- " .. vars.helium))
hl.bind(super .. "+ CTRL + 0", hl.dsp.exec_cmd("uwsm app -- " .. vars.slack))

-- === Shell ===
hl.bind(super .. "+ D", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call launcher toggle"))
hl.bind(super .. "+ C", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call controlCenter toggle"))
hl.bind(super .. "+ SHIFT + C", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call calendar toggle"))
hl.bind(super .. "+ V", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call launcher clipboard"))
hl.bind(super .. "+ B", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call bluetooth togglePanel"))
hl.bind(super .. "+ period", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call launcher emoji"))
hl.bind(super .. "+ N", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call notifications toggleHistory"))
hl.bind(super .. "+ SHIFT + N", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call notifications toggleDND"))
hl.bind(super .. "+ Y", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call wallpaper toggle"))
hl.bind(super .. "+ TAB", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call settings toggle"))

-- === Power ===
hl.bind(super .. "+" .. mod .. "+ F12", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call lockScreen lock"))
hl.bind(super .. "+" .. mod .. "+ F11", hl.dsp.exec_cmd("reboot"))
hl.bind(super .. "+" .. mod .. "+ F10", hl.dsp.exec_cmd("poweroff"))
hl.bind(super .. "+ SHIFT + E", hl.dsp.exec_cmd("uwsm stop -r"))

-- === Brightness Controls ===
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call brightness increase"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call brightness decrease"),
    { repeating = true })

-- === Window Management ===
hl.bind(super .. "+ SHIFT + Q", hl.dsp.window.close())
hl.bind(super .. "+ F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(super .. "+ SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(super .. "+ SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(super .. "+ W", hl.dsp.group.toggle())

-- === Focus Navigation ===
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))

-- === Window Movement ===
hl.bind(mod .. "+ SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. "+ SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. "+ SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. "+ SHIFT + right", hl.dsp.window.move({ direction = "r" }))

-- === Column Navigation ===
hl.bind(super .. "+ Home", hl.dsp.focus({ window = "first" }))
hl.bind(super .. "+ End", hl.dsp.focus({ window = "last" }))

-- === Monitor Navigation ===
hl.bind(mod .. "+ CTRL + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. "+ CTRL + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. "+ CTRL + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. "+ CTRL + up", hl.dsp.focus({ direction = "u" }))

-- === Move to Monitor ===
hl.bind(mod .. "+ SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mod .. "+ SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "d" }))
hl.bind(mod .. "+ SHIFT + CTRL + up", hl.dsp.window.move({ monitor = "u" }))
hl.bind(mod .. "+ SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "r" }))

-- === Special Workspace ===
hl.bind(super .. "+ P", hl.dsp.workspace.toggle_special())
hl.bind(super .. "+ SHIFT + P", hl.dsp.window.move({ workspace = "special" }))

-- === Numbered Workspaces ===
for i = 1, 9 do
    hl.bind(super .. "+" .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(super .. "+ SHIFT +" .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(super .. "+ 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(super .. "+ SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- === Mouse Wheel Navigation ===
-- hl.bind(super .. "+ mouse_down", hl.dsp.layout("move -col"))
-- hl.bind(super .. "+ mouse_up", hl.dsp.layout("move +col"))

-- === Move/Resize with Mouse ===
hl.bind(super .. "+ mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(super .. "+ mouse:273", hl.dsp.window.resize(), { mouse = true })

-- === Resize with keyboard ===
hl.bind(super .. "+ code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(super .. "+ code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

-- === Manual Sizing ===
hl.bind(super .. "+ minus", hl.dsp.window.resize({ x = "-10", y = 0, relative = true }), { repeating = true })
hl.bind(super .. "+ equal", hl.dsp.window.resize({ x = "10", y = 0, relative = true }), { repeating = true })
hl.bind(super .. "+ SHIFT + minus", hl.dsp.window.resize({ x = 0, y = "-10", relative = true }), { repeating = true })
hl.bind(super .. "+ SHIFT + equal", hl.dsp.window.resize({ x = 0, y = "10", relative = true }), { repeating = true })

-- === Screenshots ===
local date_fmt = "$(date +%Y-%m-%d_%H-%M-%S)"
hl.bind(super .. "+ S", hl.dsp.exec_cmd(
    "hyprshot -m window -m active -o " .. home .. "/Pictures/Screenshots -f Screenshot_" .. date_fmt .. ".png -s"
))
hl.bind(super .. "+ SHIFT + S", hl.dsp.exec_cmd(
    "hyprshot -m region -rz | satty --filename -"
))
hl.bind(super .. "+" .. mod .. "+ S", hl.dsp.exec_cmd(
    "hyprshot -m output -m active -o " .. home .. "/Pictures/Screenshots -f Screenshot_" .. date_fmt .. ".png -s"
))
