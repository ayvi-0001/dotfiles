local utils = require "utils"
local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

---@param cmd { args?: string[]?, cwd?: string, set_environment_variables?: table<[string], string>, domain: { ["DomainName"]:  string }, position: {x: integer, y: integer, origin: PositionOrigin}, width?: integer?, height?: integer?, workspace?: string? }
wezterm.on("gui-startup", function(cmd) ---@diagnostic disable-line: unused-local
  local _, primary_pane, primary_window = window_space.spawn_window_and_set_dimensions {
    ratio = 0.8,
    domain = "local",
    offsets = { x = 0, y = -30 },
    screen_name = "DISPLAY1: QG221Q on NVIDIA GeForce RTX 4070 SUPER",
  }
  -- start with 3 tabs
  local mux_window = primary_window:mux_window()
  mux_window:spawn_tab {}
  mux_window:spawn_tab {}

  local secondary_tab, secondary_pane, _ = window_space.spawn_window_and_set_dimensions {
    ratio = 0.9,
    domain = "local",
    screen_name = "DISPLAY2: Generic PnP Monitor on NVIDIA GeForce RTX 4070 SUPER",
    offsets = { x = 0, y = -30 },
    args = { "bash", "-c", "sudo btop4win" },
  }
  secondary_pane:split {
    args = { "bash", "-c", "sudo bandwhich --show-dns --total-utilization" },
    direction = "Bottom",
    size = 0.3,
  }
  secondary_tab:set_title "btop4win/bandwhich"

  primary_window:focus()
  primary_pane:activate()
end)

---@param window Window
---@param pane Pane
wezterm.on("spawn-new-window-80%", function(window, pane) ---@diagnostic disable-line: unused-local
  local cwd = pane:get_current_working_dir()
  ---@cast cwd Url
  cwd = utils.get_url_file_path(cwd)
  window_space.spawn_window_and_set_dimensions { ratio = 0.8, cwd = cwd, domain = "local" }
end)

---@param window Window
---@param pane Pane
wezterm.on("spawn-new-window-50%", function(window, pane) ---@diagnostic disable-line: unused-local
  local cwd = pane:get_current_working_dir()
  ---@cast cwd Url
  cwd = utils.get_url_file_path(cwd)
  window_space.spawn_window_and_set_dimensions { ratio = 0.5, cwd = cwd, domain = "local" }
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
