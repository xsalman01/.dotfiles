--[[
 ==================
  PLUGINS
 ==================
--]]

-- Guard: only configure if the plugin is loaded
if hl.plugin.dynamic_cursors ~= nil then
    hl.config({
        plugin = {
            dynamic_cursors = {
                enabled = true,
                mode    = "tilt",
                tilt = {
                    limit    = 5000,
                    func     = "negative_quadratic",  -- "function" is a reserved Lua keyword!
                    window   = 300,
                },
                shake = {
                    enabled = false,
                },
            },
        },
    })
end
