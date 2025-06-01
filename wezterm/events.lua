local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

---@param cmd? any[]
wezterm.on("gui-startup", function(cmd) ---@diagnostic disable-line: unused-local
  -- local args = {}
  -- if cmd then
  --   args = cmd.args
  -- end
  window_space.spawn_window_and_set_dimensions { ratio = 0.8, domain = "local" }
end)

---@param window Window
---@param pane Pane
wezterm.on("spawn-new-window", function(window, pane) ---@diagnostic disable-line: unused-local
  window_space.spawn_window_and_set_dimensions { ratio = 0.8, domain = "local" }
end)

---@param window Window
---@param _ Pane
wezterm.on("update-right-status", function(window, _)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name .. "  "
  end
  window:set_right_status(name or "")
end)
