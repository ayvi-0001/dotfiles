local wezterm = require "wezterm" --[[@as Wezterm]]

---@param window Window
---@param _ Pane
wezterm.on("update-right-status", function(window, _)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name .. "  "
  end
  window:set_right_status(name or "")
end)
