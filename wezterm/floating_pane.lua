local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

---@class FloatingPane
local M = {}

---Need to add binding to emit event, e.g.
---```lua
--- { key = "F", mods = "ALT", action = wezterm.action.EmitEvent "toggle-floating-pane" }
---```
---@param config Config
---@param unix_domain? UnixDomain
---@param event_name? string="toggle-floating-pane"
---@return nil
function M.apply_to_config(config, unix_domain, event_name)
  if not config.unix_domains then
    config.unix_domains = {}
  end

  local floating_pane_domain = unix_domain or {}
  floating_pane_domain.name = "local-floating"
  table.insert(config.unix_domains, floating_pane_domain)

  ---@param window Window
  ---@param pane Pane
  wezterm.on(event_name or "toggle-floating-pane", function(window, pane) ---@diagnostic disable-line: unused-local
    local domain_name = "local-floating"
    local domain = wezterm.mux.get_domain(domain_name)
    local gui_windows = wezterm.gui.gui_windows()

    if domain then
      if not domain:has_any_panes() then
        local default_prog = gui_windows[1]:effective_config()["default_prog"]
        window_space.spawn_window_and_set_dimensions { ratio = 0.4, domain = domain_name, args = default_prog }
      else
        local floating_pane
        for i in pairs(gui_windows) do
          if gui_windows[i]:active_pane():get_domain_name() == domain_name then
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
end

return M
