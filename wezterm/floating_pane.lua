local wezterm = require "wezterm"
local M = {}

local _spawn_window_and_set_dimensions = function(ratio, domain)
  local screen = wezterm.gui.screens().active
  local width, height = screen.width * ratio, screen.height * ratio
  local x = (screen.width - width) / 2
  local y = (screen.height - height) / 2

  local window = select(
    3,
    wezterm.mux.spawn_window {
      position = { x = x, y = y, origin = "ActiveScreen" },
      domain = { DomainName = domain or "local" },
    }
  )

  local k = "window-" .. window:window_id()

  wezterm.GLOBAL.window_space[k] = {}
  wezterm.GLOBAL.window_space[k]["x"] = x
  wezterm.GLOBAL.window_space[k]["y"] = y
  wezterm.GLOBAL.window_space[k]["pixel_height"] = height
  wezterm.GLOBAL.window_space[k]["pixel_width"] = width

  window:gui_window():set_inner_size(width, height)
end

wezterm.on("toggle-floating-pane", function(window, pane)
  local domain = wezterm.mux.get_domain "local-floating"

  if domain then
    if not domain:has_any_panes() then
      _spawn_window_and_set_dimensions(0.4, "local-floating")
    else
      local gui_windows = wezterm.gui.gui_windows()
      local floating_pane
      for i in pairs(gui_windows) do
        if gui_windows[i]:active_pane():get_domain_name() == "local-floating" then
          floating_pane = gui_windows[i]
        end
      end

      local active_pane = floating_pane:mux_window():active_pane()
      if floating_pane:is_focused() then
        floating_pane:perform_action(wezterm.action.Hide, active_pane)
      else
        floating_pane:perform_action(wezterm.action.Show, active_pane)
        floating_pane:focus()
      end
    end
  end
end)

function M.apply_to_config(config)
  if not wezterm.GLOBAL.window_space then
    wezterm.GLOBAL.window_space = {}
  end
  if not config.unix_domains then
    config.unix_domains = {}
  end
  table.insert(config.unix_domains, { name = "local-floating", connect_automatically = false })

  -- need to add binding:
  -- { key = , action = wezterm.action.EmitEvent "toggle-floating-pane" }
end

return M
