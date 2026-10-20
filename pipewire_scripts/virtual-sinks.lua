-- WirePlumber: virtual sinks (game_sink, chat_sink) that auto-follow the
-- user's hardware output device, with per-app routing to chat_sink.
--
-- Install: ~/.local/share/wireplumber/scripts/virtual-sinks.lua
-- Config:  50_virtual_sinks.conf
--
-- Design (v2): each virtual sink IS the capture side of a
-- libpipewire-module-loopback (media.class = Audio/Sink). There is no separate
-- null sink to tap, because WP 0.5.18 would not resolve a sink as the
-- target of a capture stream (it fell through to the default sink and created
-- a feedback loop). Only the *playback* side needs a target (the hardware
-- sink), and WP resolves that fine.
--
-- Retargeting does not destroy the modules (that would destroy the sinks and
-- kick apps off them). It sets `target.object` in the default metadata for
-- each playback node, which WP's linking scripts honour.
--
-- Behaviour:
--   * pick a device in pavucontrol ("Set as fallback") -> both sinks follow
--   * a higher-priority hardware sink appears (BT, USB) -> both sinks follow
--   * the current target disappears -> most recently used device that still
--     exists, else the highest-priority one

log = Log.open_topic ("s-virtual-sinks")

GAME_SINK = "game_sink"
CHAT_SINK = "chat_sink"
VIRTUAL_SINK_NAMES = { GAME_SINK, CHAT_SINK }
SINK_DESCRIPTIONS = { [GAME_SINK] = "Game", [CHAT_SINK] = "Chat" }

-- Persisted name of the last chosen hardware sink (survives WP restarts).
state = State ("virtual-sinks")
state_table = state:load ()
current_hw_target = state_table ["hardware-target"]

-- Most-recently-used hardware sinks, newest first (in memory only).
target_history = {}
if current_hw_target then
  table.insert (target_history, current_hw_target)
end

loopback_modules = {}

-- Hardware audio sinks only. Loopback-created sinks have no device.id, so
-- requiring it excludes them. The custom marker is belt-and-suspenders.
hw_sink_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "matches", "Audio/Sink", type = "pw-global" },
    Constraint { "device.id", "+", type = "pw" },
    Constraint { "node.virtual-sinks.owned", "!", true, type = "pw" },
  }
}

-- The playback side of our two loopbacks (so we can retarget them).
playback_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "node.virtual-sinks.loopback", "=", "true", type = "pw" },
  }
}

metadata_om = ObjectManager {
  Interest {
    type = "metadata",
    Constraint { "metadata.name", "=", "default" },
  }
}

-- ---------------------------------------------------------------------------
-- loopback creation: the loopback's capture side is the virtual sink
-- ---------------------------------------------------------------------------

function loopbackArgs (sink_name, hw_target)
  local capture_props = {
    ["node.name"] = sink_name,
    ["node.description"] = SINK_DESCRIPTIONS [sink_name],
    ["media.class"] = "Audio/Sink",
    ["audio.channels"] = "2",
    ["audio.position"] = "FL,FR",
    -- never auto-selected as a hardware default.
    ["priority.session"] = "0",
    -- marker so hw_sink_om never treats our sinks as hardware.
    ["node.virtual-sinks.owned"] = "true",
  }
  local playback_props = {
    ["node.name"] = "loopback." .. sink_name .. ".playback",
    ["target.object"] = hw_target,
    -- marker: lets playback_om find us, and keeps stream.rules away.
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

function createLoopback (sink_name, hw_target)
  log:info ("creating " .. sink_name .. " -> " .. hw_target)
  loopback_modules [sink_name] =
      LocalModule ("libpipewire-module-loopback", loopbackArgs (sink_name, hw_target), {})
end

-- Point an existing loopback's playback side at a different hardware sink.
function moveLoopback (sink_name, hw_target)
  local node = playback_om:lookup {
    Constraint { "node.name", "=", "loopback." .. sink_name .. ".playback", type = "pw" }
  }
  local md = metadata_om:lookup ()
  if not node or not md then
    log:warning ("cannot move " .. sink_name .. ": playback node or metadata missing")
    return
  end
  log:info ("moving " .. sink_name .. " -> " .. hw_target)
  md:set (node ["bound-id"], "target.object", "Spa:String", hw_target)
end

function retargetLoopbacks (hw_target)
  if not hw_target then
    log:warning ("no hardware target; leaving loopbacks as they are")
    return
  end
  for _, sink_name in ipairs (VIRTUAL_SINK_NAMES) do
    if loopback_modules [sink_name] then
      moveLoopback (sink_name, hw_target)
    else
      createLoopback (sink_name, hw_target)
    end
  end
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

function sinkPriority (node)
  return node and (tonumber (node.properties ["priority.session"]) or 0) or -1
end

-- Highest-priority hardware sink, optionally excluding one name (used when
-- that sink is in the middle of being removed).
function pickBestHwSink (exclude)
  local best, best_prio = nil, -1
  for node in hw_sink_om:iterate () do
    if hwSinkName (node) ~= exclude then
      local prio = sinkPriority (node)
      if prio > best_prio then
        best, best_prio = node, prio
      end
    end
  end
  return best
end

-- Fallback when the current target vanishes: most recently used sink that
-- still exists, otherwise the highest-priority remaining sink.
function pickFallback (removed)
  for _, n in ipairs (target_history) do
    if n ~= removed and findHwSink (n) then return n end
  end
  return hwSinkName (pickBestHwSink (removed))
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

-- Record the new target. Never persists nil, so a moment with no hardware
-- sink does not wipe the saved choice.
function saveHwTarget (name)
  current_hw_target = name
  if not name then return end
  for i, v in ipairs (target_history) do
    if v == name then
      table.remove (target_history, i)
      break
    end
  end
  table.insert (target_history, 1, name)
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

  if not target_name then
    -- no hardware sink yet; wait for one (object-added will initialise us)
    log:warning ("no hardware sink yet; waiting")
    return
  end

  saveHwTarget (target_name)
  retargetLoopbacks (target_name)

  -- make game_sink the configured default so new apps route through it.
  setConfiguredDefaultSink (GAME_SINK)

  initialised = true
  log:info ("initialised; hardware target = " .. tostring (target_name))
end

-- ---------------------------------------------------------------------------
-- react to the user manually changing the output device (pavucontrol etc.)
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
    if not initialised then return end
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
-- react to hardware sinks appearing/disappearing
-- ---------------------------------------------------------------------------

hw_sink_om:connect ("object-added", function (_, node)
  if not initialised then
    scheduleInit ()
    return
  end
  local name = hwSinkName (node)
  local new_prio = sinkPriority (node)
  local cur = findHwSink (current_hw_target)
  local cur_prio = cur and sinkPriority (cur) or -1

  -- mimic WirePlumber: a new sink only becomes the target if it outranks the
  -- current one (BT headsets / USB DACs usually do; HDMI usually doesn't).
  if new_prio > cur_prio then
    log:info ("hardware sink appeared with higher priority -> " .. tostring (name) ..
        " (" .. new_prio .. " > " .. cur_prio .. ")")
    saveHwTarget (name)
    retargetLoopbacks (name)
    setConfiguredDefaultSink (GAME_SINK)
  else
    log:info ("hardware sink appeared, lower priority; keeping " ..
        tostring (current_hw_target) .. " (" .. tostring (name) ..
        " prio " .. new_prio .. " <= " .. cur_prio .. ")")
  end
end)

hw_sink_om:connect ("object-removed", function (_, node)
  if not initialised then return end
  local name = hwSinkName (node)
  -- if our current target vanished, fall back to the last-used device that
  -- still exists (else the best remaining sink).
  if current_hw_target == name then
    local new_name = pickFallback (name)
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
playback_om:activate ()
metadata_om:activate ()

-- safety net: if no hardware sink and no metadata event fires within 2s,
-- try to initialise anyway.
Core.timeout_add (2000, function ()
  if not initialised then initialise () end
end)
