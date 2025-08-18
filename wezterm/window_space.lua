local wezterm = require "wezterm" --[[@as Wezterm]]

---@class WindowSpace
local M = {}

--[[
Module for setting the size of spawned/detached gui windows and centering them on the screen.
Window coordinates & dimensions are saved in wezterm's global in-memory table,
and are used to move and resize the window through custom events.

Load into wezterm.lua

```lua
require("window_space").setup {
  enable_window_resize_events = true,
  enable_window_move_events = true,
  -- optional
  resize_increment = 25
  move_increment = 25 
}
```

Module functions:
  - spawn_window_and_set_dimensions
  - move_pane_to_new_window

Module events:
  - "increase-to-top"
  - "decrease-from-top"
  - "increase-to-bottom"
  - "decrease-from-bottom"
  - "increase-to-left"
  - "decrease-from-left"
  - "increase-to-right"
  - "decrease-from-right"
  - "move-window-left"
  - "move-window-right"
  - "move-window-up"
  - "move-window-down"
--]]

---@param window Window
---@return string
local function _window_key(window)
  return "window-" .. window:window_id()
end

---@class SpawnWindowOpts
---@field ratio number
---@field domain? string
---@field cwd? string
---@field screen_name? "active"|"main"|string = "active"
---@field offsets? { x?: number, y?: number }
---@field args? string[]

---@param opts SpawnWindowOpts
---@return MuxTabObj, Pane, Window
function M.spawn_window_and_set_dimensions(opts)
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
    cwd = opts.cwd,
    position = { x = x, y = y, origin = "ActiveScreen" },
    domain = { DomainName = opts.domain or "local" },
  }

  local gui_window = mux_window:gui_window() --[[@as Window]]

  local k = _window_key(gui_window)
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

---@param window Window
---@param pane Pane
---@return nil
function M.move_pane_to_new_window(window, pane)
  local _, new_mux_window = pane:move_to_new_window()
  local new_window = new_mux_window:gui_window()

  local ck = _window_key(window)
  local nk = _window_key(new_window)

  wezterm.GLOBAL.window_space[nk] = wezterm.GLOBAL.window_space[ck]

  local x = wezterm.GLOBAL.window_space[nk]["x"]
  local y = wezterm.GLOBAL.window_space[nk]["y"]
  local pixel_width = wezterm.GLOBAL.window_space[nk]["pixel_width"]
  local pixel_height = wezterm.GLOBAL.window_space[nk]["pixel_height"]

  new_window:set_position(x, y)
  new_window:set_inner_size(pixel_width, pixel_height)
end

---@private
---@param window Window
---@param axis "x"|"y"
---@param direction "right"|"down"|"left"|"up"
---@param increment integer
---@return nil
function M._set_position(window, axis, direction, increment)
  if not window then
    return
  end

  local k = _window_key(window)
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

---@private
---@param window Window
---@param dimension "width"|"height"
---@param direction "increase"|"decrease"
---@param increment integer
---@return nil
function M._set_inner_size(window, dimension, direction, increment)
  if not window then
    return
  end

  local k = _window_key(window)
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

---@class WindowSpaceOpts
---@field enable_window_resize_events? boolean
---@field enable_window_move_events? boolean
---@field resize_increment? integer=25
---@field move_increment? integer=25

---@param opts WindowSpaceOpts
---@return nil
function M.setup(opts)
  if opts.enable_window_resize_events then
    local resize_increment = opts.resize_increment or 25

    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-increase-to-top", function(window, _)
      M._set_position(window, "y", "up", resize_increment)
      M._set_inner_size(window, "height", "increase", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-decrease-from-top", function(window, _)
      M._set_position(window, "y", "down", resize_increment)
      M._set_inner_size(window, "height", "decrease", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-increase-to-bottom", function(window, _)
      M._set_inner_size(window, "height", "increase", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-decrease-from-bottom", function(window, _)
      M._set_inner_size(window, "height", "decrease", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-increase-to-left", function(window, _)
      M._set_position(window, "x", "up", resize_increment)
      M._set_inner_size(window, "width", "increase", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-decrease-from-left", function(window, _)
      M._set_position(window, "x", "down", resize_increment)
      M._set_inner_size(window, "width", "decrease", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-increase-to-right", function(window, _)
      M._set_inner_size(window, "width", "increase", resize_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("resize-window-decrease-from-right", function(window, _)
      M._set_inner_size(window, "width", "decrease", resize_increment)
    end)
  end

  if opts.enable_window_move_events then
    local move_increment = opts.move_increment or 25

    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("move-window-left", function(window, _)
      M._set_position(window, "x", "left", move_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("move-window-right", function(window, _)
      M._set_position(window, "x", "right", move_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("move-window-up", function(window, _)
      M._set_position(window, "y", "up", move_increment)
    end)
    ---@overload fun(window: Window, _: Pane): nil
    wezterm.on("move-window-down", function(window, _)
      M._set_position(window, "y", "down", move_increment)
    end)
  end
end

return M
