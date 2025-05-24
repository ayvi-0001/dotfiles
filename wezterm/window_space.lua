local wezterm = require "wezterm" --[[@as Wezterm]]

local E = {}

-- events below are for setting the size of spawned gui windows and centering them on the screen.
-- the x/y coordinates and dimensions are saved in wezterm's global in-memory table,
-- and are used to move and resize the window through custom events.
-- this is unfinished and very experimental.

---@param ratio number
---@param domain string
---@param args? string[]
---@return MuxTabObj, Pane, Window
E.spawn_window_and_set_dimensions = function(ratio, domain, args)
  local screen = wezterm.gui.screens().active
  local width, height = screen.width * ratio, screen.height * ratio
  local x = (screen.width - width) / 2
  local y = (screen.height - height) / 2

  local mux_tab, pane, mux_window = wezterm.mux.spawn_window {
    args = args,
    position = { x = x, y = y, origin = "ActiveScreen" },
    domain = { DomainName = domain or "local" },
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

---@param cmd? any
wezterm.on("gui-startup", function(cmd) ---@diagnostic disable-line: unused-local
  -- local args = {}
  -- if cmd then
  --   args = cmd.args
  -- end
  E.spawn_window_and_set_dimensions(0.8, "local")
end)

wezterm.on("spawn-new-window", function(_, _)
  E.spawn_window_and_set_dimensions(0.8, "local")
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
