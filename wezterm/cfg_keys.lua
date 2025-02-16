local wezterm = require "wezterm"
local module = {}

wezterm.on("update-right-status", function(window, pane)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name
  end
  window:set_right_status(name or "")
end)

function module.apply_to_config(config)
  config.leader = { key = "Space", mods = "CTRL|SHIFT" }

  config.keys = {
    {
      key = "p",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "pane_mode",
        timeout_milliseconds = 1000,
      },
    },
    {
      key = "n",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "resize_mode",
        one_shot = false,
        timeout_milliseconds = 1000,
      },
    },
    {
      key = "h",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "move_mode",
        timeout_milliseconds = 1000,
      },
    },
    {
      key = "t",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "tab_mode",
        one_shot = false,
        timeout_milliseconds = 1000,
      },
    },
    {
      key = "w",
      mods = "SHIFT|CTRL",
      action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    { key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Left" },
    { key = "h", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Left" },
    { key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Right" },
    { key = "l", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Right" },
    { key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Down" },
    { key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Down" },

    { key = "H", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "L", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },

    { key = "i", mods = "ALT", action = wezterm.action.MoveTabRelative(-1) },
    { key = "o", mods = "ALT", action = wezterm.action.MoveTabRelative(1) },

    {
      key = "C",
      mods = "CTRL|SHIFT",
      action = wezterm.action.CopyTo "ClipboardAndPrimarySelection",
    },
    { key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom "Clipboard" },
    { key = "L", mods = "CTRL|SHIFT", action = wezterm.action.ShowDebugOverlay },
    { key = "l", mods = "ALT|LEADER", action = wezterm.action.ShowLauncher },
    { key = "P", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette },
    { key = "t", mods = "CTRL|ALT", action = wezterm.action.ReloadConfiguration },
    { key = "R", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
    { key = "r", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
    {
      key = "DownArrow",
      mods = "CTRL|SHIFT|ALT",
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = "LeftArrow",
      mods = "CTRL|SHIFT|ALT",
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = "RightArrow",
      mods = "CTRL|SHIFT|ALT",
      action = wezterm.action.DisableDefaultAssignment,
    },
    { key = "UpArrow", mods = "CTRL|SHIFT|ALT", action = wezterm.action.DisableDefaultAssignment },
    { key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
    { key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
    { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
    { key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
    { key = '"', mods = "CTRL|SHIFT|ALT", action = wezterm.action.DisableDefaultAssignment }, -- SplitVertical
    { key = "%", mods = "CTRL|SHIFT|ALT", action = wezterm.action.DisableDefaultAssignment }, -- SplitHorizontal
    { key = "Z", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment }, -- ActivateCopyMode
    { key = "U", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment }, -- CharSelect
    { key = "X", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment }, -- ActivateCopyMode
  }

  config.key_tables = {
    resize_mode = {
      { key = "LeftArrow", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
      { key = "h", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
      { key = "DownArrow", action = wezterm.action.AdjustPaneSize { "Down", 5 } },
      { key = "j", action = wezterm.action.AdjustPaneSize { "Down", 5 } },
      { key = "UpArrow", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
      { key = "k", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
      { key = "RightArrow", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
      { key = "l", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
      { key = "Escape", action = "PopKeyTable" },
    },

    move_mode = {
      {
        key = "h",
        action = wezterm.action.Multiple {
          wezterm.action.RotatePanes "CounterClockwise",
          wezterm.action.ActivatePaneDirection "Prev",
        },
      },
      {
        key = "l",
        action = wezterm.action.Multiple {
          wezterm.action.RotatePanes "Clockwise",
          wezterm.action.ActivatePaneDirection "Next",
        },
      },
      { key = "Escape", action = "PopKeyTable" },
    },

    tab_mode = {
      { key = "n", action = wezterm.action.SpawnTab "CurrentPaneDomain" },
      { key = "x", action = wezterm.action.CloseCurrentTab { confirm = false } },
      { key = "h", action = wezterm.action.ActivateTabRelative(-1) },
      { key = "l", action = wezterm.action.ActivateTabRelative(1) },

      { key = "1", action = wezterm.action.ActivateWindow(0) },
      { key = "2", action = wezterm.action.ActivateWindow(1) },
      { key = "3", action = wezterm.action.ActivateWindow(2) },
      { key = "4", action = wezterm.action.ActivateWindow(3) },
      { key = "5", action = wezterm.action.ActivateWindow(4) },
      { key = "6", action = wezterm.action.ActivateWindow(5) },
      { key = "7", action = wezterm.action.ActivateWindow(6) },
      { key = "8", action = wezterm.action.ActivateWindow(7) },
      { key = "9", action = wezterm.action.ActivateWindow(8) },

      { key = "Escape", action = "PopKeyTable" },
    },

    pane_mode = {
      { key = "d", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
      { key = "r", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
      { key = "x", action = wezterm.action.CloseCurrentPane { confirm = false } },
      {
        key = "w",
        action = wezterm.action.Multiple {
          wezterm.action_callback(
            function(win, pane)
              wezterm.mux.spawn_window {
                args = { "bash", "-il" },
                width = 150,
                height = 30,
                position = { x = 770, y = 400, origin = "ScreenCoordinateSystem" },
              }
            end
          ),
          wezterm.action.ToggleAlwaysOnTop,
        },
      },
      { key = "Escape", action = "PopKeyTable" },
    },
  }

  config.mouse_bindings = {
    -- Disable the default click behavior
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "NONE",
      action = wezterm.action.DisableDefaultAssignment,
    },
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
    -- Disable the Ctrl-click down event to stop programs from seeing it when a URL is clicked
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.Nop,
    },
  }
end

return module
