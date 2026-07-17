-- WirePlumber: virtual sinks (game_sink, chat_sink) that auto-follow the
-- user's hardware output device, with per-app routing to chat_sink.
--
-- Install: ~/.config/wireplumber/scripts/virtual-sinks.lua
-- Config:  50-virtual-sinks.conf (companion file in this directory)
-- Full design + verification checklist: IMPLEMENTATION.mdx

log = Log.open_topic ("s-virtual-sinks")

GAME_SINK = "game_sink"
CHAT_SINK = "chat_sink"
VIRTUAL_SINK_NAMES = { GAME_SINK, CHAT_SINK }

-- Persisted name of the last chosen hardware sink (survives WP restarts).
state = State ("virtual-sinks")
state_table = state:load ()
current_hw_target = state_table ["hardware-target"]

sink_nodes = {}
loopback_modules = {}

-- Hardware audio sinks only: null sinks have no device.id, so requiring it
-- present excludes virtual sinks. The custom marker is belt-and-suspenders.
hw_sink_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "matches", "Audio/Sink", type = "pw-global" },
    Constraint { "device.id", "+", type = "pw" },
    Constraint { "node.virtual-sinks.owned", "!", true, type = "pw" },
  }
}

metadata_om = ObjectManager {
  Interest {
    type = "metadata",
    Constraint { "metadata.name", "=", "default" },
  }
}

-- ---------------------------------------------------------------------------
-- null sink creation
-- ---------------------------------------------------------------------------

function createNullSink (name, description)
  local properties = {
    ["node.name"] = name,
    ["node.description"] = description,
    ["audio.rate"] = "48000",
    ["audio.channels"] = "2",
    ["audio.position"] = "FL,FR",
    ["media.class"] = "Audio/Sink",
    ["factory.name"] = "support.null-audio-sink",
    ["node.virtual"] = "true",
    -- monitor volume tracks the sink volume, so `pactl set-sink-volume`
    -- propagates through the loopback to the hardware device.
    ["monitor.channel-volumes"] = "true",
    -- tag so WP's own fallback-sink.lua ignores our sinks.
    ["wireplumber.is-virtual"] = "true",
    -- custom marker so our hw_sink_om filter can exclude them.
    ["node.virtual-sinks.owned"] = "true",
    -- never auto-selected as a hardware default.
    ["priority.session"] = "0",
  }
  local node = LocalNode ("adapter", properties)
  node:activate (Feature.Proxy.BOUND)
  return node
end

-- ---------------------------------------------------------------------------
-- loopback creation (game_sink.monitor -> hardware, chat_sink.monitor -> hw)
-- ---------------------------------------------------------------------------

function loopbackArgs (sink_name, hw_target)
  local capture_props = {
    ["node.name"] = "loopback." .. sink_name .. ".capture",
    -- capture from the monitor of our virtual sink (NOT a real source):
    ["target.object"] = sink_name,
    ["stream.capture.sink"] = "true",
    ["node.passive"] = "true",
    -- we manage retargeting ourselves (destroy + recreate on device change).
    ["node.dont-reconnect"] = "true",
    -- marker so stream.rules never re-route the loopback's own streams.
    ["node.virtual-sinks.loopback"] = "true",
    ["state.restore-props"] = "false",
    ["state.restore-target"] = "false",
  }
  local playback_props = {
    ["node.name"] = "loopback." .. sink_name .. ".playback",
    ["target.object"] = hw_target,
    ["node.dont-reconnect"] = "true",
    ["node.virtual-sinks.loopback"] = "true",
    ["state.restore-props"] = "false",
    ["state.restore-target"] = "false",
  }
  local args = Json.Object {
    ["capture.props"] = Json.Object (capture_props),
    ["playback.props"] = Json.Object (playback_props),
  }
  return args:get_data ()
end

function applyLoopback (sink_name, hw_target)
  -- destroy the previous instance first (drop ref + force GC) to avoid a
  -- brief double-audio overlap when retargeting.
  if loopback_modules [sink_name] then
    loopback_modules [sink_name] = nil
    pcall (function () collectgarbage ("collect") end)
  end
  if not hw_target then
    log:warning ("no hardware target; skipping loopback for " .. sink_name)
    return
  end
  log:info ("loopback " .. sink_name .. " -> " .. hw_target)
  loopback_modules [sink_name] =
      LocalModule ("libpipewire-module-loopback", loopbackArgs (sink_name, hw_target), {})
end

function retargetLoopbacks (hw_target)
  applyLoopback (GAME_SINK, hw_target)
  applyLoopback (CHAT_SINK, hw_target)
end

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

function findHwSink (name)
  if not name then return nil end
  return hw_sink_om:lookup {
    Constraint { "node.name", "=", name, type = "pw" }
  }
end

function hwSinkName (node)
  return node and node.properties ["node.name"] or nil
end

function pickBestHwSink ()
  local best, best_prio = nil, -1
  for node in hw_sink_om:iterate () do
    local prio = tonumber (node.properties ["priority.session"]) or 0
    if prio > best_prio then
      best, best_prio = node, prio
    end
  end
  return best
end

-- Read the resolved default sink name ("default.audio.sink") from metadata.
-- Defensive: returns nil if metadata is unavailable or the format is unknown.
function getCurrentDefaultSinkName ()
  local md = metadata_om:lookup ()
  if not md then return nil end
  local ok, value = pcall (function () return md:find (0, "default.audio.sink") end)
  if not ok or not value then return nil end
  local jok, json = pcall (function () return Json.Raw (value) end)
  if not jok or not json or not json:is_object () then return nil end
  local pok, parsed = pcall (function () return json:parse () end)
  if not pok or type (parsed) ~= "table" then return nil end
  return parsed ["name"]
end

-- Set the *configured* default sink (the user preference WP resolves the
-- actual default from). This is what volume apps change when you pick a device.
function setConfiguredDefaultSink (name)
  local md = metadata_om:lookup ()
  if not md then
    log:warning ("default metadata unavailable; cannot set configured default")
    return
  end
  md:set (0, "default.configured.audio.sink", "Spa:String:JSON",
      Json.Object { ["name"] = name }:to_string ())
end

function saveHwTarget (name)
  current_hw_target = name
  state_table ["hardware-target"] = name
  state:save_after_timeout (state_table)
end

-- ---------------------------------------------------------------------------
-- initialisation (runs once both OMs have settled)
-- ---------------------------------------------------------------------------

initialised = false
init_timer = nil

function scheduleInit ()
  if init_timer then init_timer:destroy () end
  init_timer = Core.timeout_add (500, function ()
    init_timer = nil
    initialise ()
  end)
end

function initialise ()
  if initialised then return end

  if not sink_nodes [GAME_SINK] then
    sink_nodes [GAME_SINK] = createNullSink (GAME_SINK, "Game")
  end
  if not sink_nodes [CHAT_SINK] then
    sink_nodes [CHAT_SINK] = createNullSink (CHAT_SINK, "Chat")
  end

  -- resolve the initial hardware target, in priority order:
  --   1. saved name (from state) that still exists
  --   2. the current resolved default, if it is a hardware sink
  --   3. the highest-priority hardware sink
  local target_name = nil
  if current_hw_target and findHwSink (current_hw_target) then
    target_name = current_hw_target
  else
    local def = getCurrentDefaultSinkName ()
    if def and findHwSink (def) then
      target_name = def
    else
      target_name = hwSinkName (pickBestHwSink ())
    end
  end

  saveHwTarget (target_name)
  retargetLoopbacks (target_name)

  -- make game_sink the configured default so new apps route through it.
  setConfiguredDefaultSink (GAME_SINK)

  initialised = true
  log:info ("initialised; hardware target = " .. tostring (target_name))
end

-- ---------------------------------------------------------------------------
-- react to the user manually changing the output device
-- ---------------------------------------------------------------------------

default_changed_hook = SimpleEventHook {
  name = "virtual-sinks/default-configured-sink-changed",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "metadata-changed" },
      Constraint { "metadata.name", "=", "default" },
      Constraint { "event.subject.key", "=", "default.configured.audio.sink" },
    },
  },
  execute = function (event)
    local props = event:get_properties ()
    local new_value = props ["event.subject.value"]
    if not new_value then return end

    local ok, json = pcall (function () return Json.Raw (new_value) end)
    if not ok or not json or not json:is_object () then return end
    local pok, parsed = pcall (function () return json:parse () end)
    if not pok or type (parsed) ~= "table" then return end
    local new_name = parsed ["name"]
    if not new_name then return end

    -- ignore changes to our own virtual sinks (e.g. our own reset below)
    for _, v in ipairs (VIRTUAL_SINK_NAMES) do
      if new_name == v then return end
    end

    -- only act when the new configured default is a hardware sink
    if not findHwSink (new_name) then
      log:debug ("configured default '" .. tostring (new_name) ..
          "' is not a known hardware sink; ignoring")
      return
    end

    log:info ("hardware output changed -> " .. new_name)
    saveHwTarget (new_name)
    retargetLoopbacks (new_name)
    -- reset the configured default back to game_sink so new apps keep
    -- routing through the virtual sinks (this re-triggers the hook, which
    -- returns early because game_sink is a virtual sink -> no loop).
    setConfiguredDefaultSink (GAME_SINK)
  end
}:register ()

-- ---------------------------------------------------------------------------
-- react to hardware sinks appearing/disappearing (BT connect/disconnect,
-- USB DAC plug/unplug, profile changes)
-- ---------------------------------------------------------------------------

hw_sink_om:connect ("object-added", function (_, node)
  if not initialised then
    scheduleInit ()
    return
  end
  local name = hwSinkName (node)
  -- a new hardware sink appeared mid-session -> retarget to it (the user
  -- just connected a device and most likely wants to use it).
  log:info ("hardware sink appeared -> " .. tostring (name))
  saveHwTarget (name)
  retargetLoopbacks (name)
  setConfiguredDefaultSink (GAME_SINK)
end)

hw_sink_om:connect ("object-removed", function (_, node)
  if not initialised then return end
  local name = hwSinkName (node)
  -- if our current target vanished, fall back to the best remaining sink.
  if current_hw_target == name then
    local new_name = hwSinkName (pickBestHwSink ())
    log:info ("hardware target removed -> " .. tostring (new_name))
    saveHwTarget (new_name)
    retargetLoopbacks (new_name)
  end
end)

-- ensure game_sink is (re)set as configured default once metadata appears,
-- in case it wasn't ready during the first initialise().
metadata_om:connect ("object-added", function (_, md)
  if not initialised then
    scheduleInit ()
  else
    setConfiguredDefaultSink (GAME_SINK)
  end
end)

-- ---------------------------------------------------------------------------
-- activate
-- ---------------------------------------------------------------------------

hw_sink_om:activate ()
metadata_om:activate ()

-- safety net: if no hardware sink and no metadata event fires within 2s,
-- initialise anyway (sinks get created; loopbacks wait for a hw sink).
Core.timeout_add (2000, function ()
  if not initialised then initialise () end
end)
