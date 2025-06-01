local wezterm = require "wezterm" --[[@as Wezterm]]

local E = {}

-- events below are for setting the size of spawned gui windows and centering them on the screen.
-- the x/y coordinates and dimensions are saved in wezterm's global in-memory table,
-- and are used to move and resize the window through custom events.
-- this is unfinished and very experimental.

---@class SpawnWindowOpts
---@field ratio number
---@field domain string
---@field screen_name? "active"|"main"|string = "active"
---@field offsets? { x?: number, y?: number }
---@field args? string[]

---@param opts SpawnWindowOpts
---@return MuxTabObj, Pane, Window
E.spawn_window_and_set_dimensions = function(opts)
  local screen
  local screen_name = opts.screen_name or "main"
  if screen_name == "active" then
    screen = wezterm.gui.screens().active
  elseif screen_name == "main" then
    screen = wezterm.gui.screens().main
  else
    screen = wezterm.gui.screens().by_name[screen_name]
  end

  local width, height = screen.width * opts.ratio, screen.height * opts.ratio
  local x = screen.x
  local y = screen.y

  if opts.offsets then
    if opts.offsets.x then
      x = x + opts.offsets.x
    end
    if opts.offsets.y then
      y = y + opts.offsets.y
    end
  end

  x = x + ((screen.width - width) / 2)
  y = y + ((screen.height - height) / 2)

  local mux_tab, pane, mux_window = wezterm.mux.spawn_window {
    args = opts.args,
    position = { x = x, y = y, origin = "ActiveScreen" },
    domain = { DomainName = opts.domain or "local" },
  }

  local gui_window = mux_window:gui_window() --[[@as Window]]

  local k = "window-" .. mux_window:window_id()
  if not wezterm.GLOBAL.window_space then
    wezterm.GLOBAL.window_space = {}
  end
  wezterm.GLOBAL.window_space[k] = {}
  wezterm.GLOBAL.window_space[k]["x"] = x
  wezterm.GLOBAL.window_space[k]["y"] = y
  wezterm.GLOBAL.window_space[k]["pixel_height"] = height
  wezterm.GLOBAL.window_space[k]["pixel_width"] = width

  gui_window:set_inner_size(width, height)
  return mux_tab, pane, gui_window
end

---@param cmd? any[]
wezterm.on("gui-startup", function(cmd) ---@diagnostic disable-line: unused-local
  -- local args = {}
  -- if cmd then
  --   args = cmd.args
  -- end
  E.spawn_window_and_set_dimensions { ratio = 0.8, domain = "local" }
end)

---@param window Window
---@param pane Pane
wezterm.on("spawn-new-window", function(window, pane) ---@diagnostic disable-line: unused-local
  E.spawn_window_and_set_dimensions { ratio = 0.8, domain = "local" }
end)

---@param window Window
---@param axis "x"|"y"
---@param direction "right"|"down"|"left"|"up"
---@param increment integer
---@private
E.set_position = function(window, axis, direction, increment)
  if not window then
    return
  end

  local k = "window-" .. window:window_id()
  if not wezterm.GLOBAL.window_space[k] then
    return
  end

  local d
  if direction == "right" or direction == "down" then
    d = wezterm.GLOBAL.window_space[k][axis] + (increment or 10)
  elseif direction == "left" or direction == "up" then
    d = wezterm.GLOBAL.window_space[k][axis] - (increment or 10)
  end

  if axis == "x" then
    window:set_position(d, wezterm.GLOBAL.window_space[k]["y"])
  elseif axis == "y" then
    window:set_position(wezterm.GLOBAL.window_space[k]["x"], d)
  end

  wezterm.GLOBAL.window_space[k][axis] = d
end

---@param window Window
---@param dimension "width"|"height"
---@param direction "increase"|"decrease"
---@param increment integer
---@private
E.set_inner_size = function(window, dimension, direction, increment)
  if not window then
    return
  end

  local k = "window-" .. window:window_id()

  if not wezterm.GLOBAL.window_space[k] then
    return
  end

  dimension = "pixel_" .. dimension

  local d
  if direction == "increase" then
    d = wezterm.GLOBAL.window_space[k][dimension] + (increment or 50)
  elseif direction == "decrease" then
    d = wezterm.GLOBAL.window_space[k][dimension] - (increment or 50)
  end

  if dimension == "pixel_width" then
    window:set_inner_size(d, wezterm.GLOBAL.window_space[k]["pixel_height"])
  elseif dimension == "pixel_height" then
    window:set_inner_size(wezterm.GLOBAL.window_space[k]["pixel_width"], d)
  end

  wezterm.GLOBAL.window_space[k][dimension] = d
end

wezterm.on("increase-to-top", function(window, _)
  E.set_position(window, "y", "up", 25)
  E.set_inner_size(window, "height", "increase", 25)
end)

wezterm.on("decrease-from-top", function(window, _)
  E.set_position(window, "y", "down", 25)
  E.set_inner_size(window, "height", "decrease", 25)
end)

wezterm.on("increase-to-bottom", function(window, _)
  E.set_inner_size(window, "height", "increase", 25)
end)

wezterm.on("decrease-from-bottom", function(window, _)
  E.set_inner_size(window, "height", "decrease", 25)
end)

wezterm.on("increase-to-left", function(window, _)
  E.set_position(window, "x", "up", 25)
  E.set_inner_size(window, "width", "increase", 25)
end)

wezterm.on("decrease-from-left", function(window, _)
  E.set_position(window, "x", "down", 25)
  E.set_inner_size(window, "width", "decrease", 25)
end)

wezterm.on("increase-to-right", function(window, _)
  E.set_inner_size(window, "width", "increase", 25)
end)

wezterm.on("decrease-from-right", function(window, _)
  E.set_inner_size(window, "width", "decrease", 25)
end)

wezterm.on("move-window-left", function(window, _)
  E.set_position(window, "x", "left", 25)
end)

wezterm.on("move-window-right", function(window, _)
  E.set_position(window, "x", "right", 25)
end)

wezterm.on("move-window-up", function(window, _)
  E.set_position(window, "y", "up", 25)
end)

wezterm.on("move-window-down", function(window, _)
  E.set_position(window, "y", "down", 25)
end)

return E
