local os = require "os"
local wezterm = require "wezterm"

wezterm.on("window-config-reloaded", function(window, pane)
  WEZTERM_LOG = os.getenv "WEZTERM_LOG"
  if WEZTERM_LOG and WEZTERM_LOG:find "config=debug" then
    window:toast_notification("wezterm", "config reloaded", nil, 1000)
  end
end)

wezterm.on("update-right-status", function(window, pane)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name .. "  "
  end
  window:set_right_status(name or "")
end)
